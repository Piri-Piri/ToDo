//
//  TaskTableViewController.swift
//  ToDo
//
//  Created by David Pirih on 16.07.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import UIKit
import CoreData

extension TaskTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            print("Task: Insert")
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            print("Task: Delete")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            print("Task: Move")
            tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        case .Update:
            print("Task: Update")
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        }
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
        
        updateTimer?.invalidate()
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: tableView, selector: "reloadData", userInfo: nil, repeats: false)
        
        // notify watch app about a data change
        DataShare.addCommand(kPhoneChangedData)
    }
}

class TaskTableViewController: UITableViewController {
    
    private var fontSizeChangeObserver: NSObjectProtocol!
    
    private var updateTimer: NSTimer!
    private var dataShareTimer: NSTimer!
    
    var job: Job! {
        didSet {
            title = job.name
        }
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController! = {
        let request = NSFetchRequest(entityName: kTaskEntity)
        request.sortDescriptors = [NSSortDescriptor(key: kTaskOrderAttribute, ascending: true)]
        request.predicate = NSPredicate(format: "job == %@", self.job)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreData.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return fetchedResultsController
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addTaskButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addTask:")
        let editButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Organize, target: self, action: "toggleEditMode:")
        let deleteAllButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "deleteAll:")
        navigationItem.setRightBarButtonItems([addTaskButton, editButton, deleteAllButton], animated: true)
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fontSizeChangeObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIContentSizeCategoryDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
            [weak self] (notification) -> Void in
                self?.tableView.reloadData()
        }
        dataShareTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "checkDataShareForAvailableCommand", userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(fontSizeChangeObserver)
        updateTimer?.invalidate()
        dataShareTimer.invalidate()
    }

    // MARK: - Helpers
    
    func checkDataShareForAvailableCommand() {
        if DataShare.wasCommandAvailable(kWatchChangedData) {
            CoreData.sharedInstance.managedObjectContext.reset()
            tableView.reloadData()
        }
    }
    
    // MARK: - BarButtonItem actions
    
    func addTask(sender: UIBarButtonItem) {
        let title = NSLocalizedString("titleCreateTaskDialog", value: "Create new Task", comment: "title in alertContoller")
        let placeholder = NSLocalizedString("placeholderCreateTaskDialog", value: "Task", comment: "placeholder for input textField")
        let message = NSLocalizedString("messageCreateTaskDialog", value: "Type in or dictate a taskname.\nPress \'Add\' to save and continue adding new tasks.\nPress \'Cancel\' if you have complete yout list for now.", comment: "message in alertController")
        let defaultLabel = NSLocalizedString("defaultButtonCreateTaskDialog", value: "Add", comment: "default button label text")
        let cancelLabel = NSLocalizedString("cancelButtonCreateTaskDialog", value: "Cancel", comment: "cancel button label text")
        
        let dialog = PPHelper.singleTextFieldDialogWithTitle(title, message: message, placeholder: placeholder, textFieldValue: "", defaultLabel: defaultLabel, cancelLabel: cancelLabel) { [weak self] (text) -> Void in
            Task.createTaskForJob(self!.job, withName: text)
            PPHelper.delayOnMainQueue(0.3) { self!.addTask(sender) }
        }
        
        presentViewController(dialog, animated: true, completion: nil)
    }
    
    func toggleEditMode(sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.editing, animated: true)
        sender.tintColor = tableView.editing ? UIColor.redColor() : self.view.tintColor
    }
    
    func deleteAll(sender: UIBarButtonItem) {
        let title = NSLocalizedString("titleDeleteAllTaskDialog", value: "Delete All Tasks", comment: "title in alertContoller")
        let message = NSLocalizedString("messageDeleteAllTaskDialog", value: "Do you really want to delete ALL tasks?", comment: "message in alertController")
        let defaultLabel = NSLocalizedString("defaultButtonDeleteAllTasksDialog", value: "Yes, delete ALL tasks", comment: "default button label text")
        let cancelLabel = NSLocalizedString("cancelButtonDeleteAllTasksDialog", value: "Cancel", comment: "cancel button label text")
        
        let dialog = PPHelper.dialogWithTitle(title, message: message, defaultLabel: defaultLabel, cancelLabel: cancelLabel) { self.job.deleteAllTasks() }
        
        presentViewController(dialog, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kTaskTableViewCell, forIndexPath: indexPath) as! TaskTableViewCell
        
        cell.task = fetchedResultsController.objectAtIndexPath(indexPath) as! Task
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            guard let task = fetchedResultsController.objectAtIndexPath(indexPath) as? Task else { return }
            task.delete()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let task = fetchedResultsController.objectAtIndexPath(indexPath) as! Task
        task.switchCompleted()
    }
    
    override func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        guard let taskCell = tableView.cellForRowAtIndexPath(indexPath) as? TaskTableViewCell else { return }
        taskCell.interactionAllowed = false
    }
    
    override func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        guard let taskCell = tableView.cellForRowAtIndexPath(indexPath) as? TaskTableViewCell else { return }
        taskCell.interactionAllowed = true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return }
        
        let source = fetchedResultsController.objectAtIndexPath(sourceIndexPath) as! NSManagedObject
        let destination = fetchedResultsController.objectAtIndexPath(destinationIndexPath) as! NSManagedObject
        
        CoreData.moveEntity(kTaskEntity, orderAtribute: kTaskOrderAttribute, source: source, toDestination: destination, predicate: NSPredicate(format: "job == %@", job))
    }

}
