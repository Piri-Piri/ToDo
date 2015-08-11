//
//  JobTableViewController.swift
//  ToDo
//
//  Created by David Pirih on 21.06.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import UIKit
import CoreData

extension JobTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                //print("Job: Insert")
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            case .Delete:
                //print("Job: Delete")
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            case .Move:
                //print("Job: Move")
                tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
            case .Update:
                //print("Job: Update")
                tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        }
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
        // notify watch app about a data change
        DataShare.addCommand(kPhoneChangedData)
    }
}

class JobTableViewController: UITableViewController {
    
    private var dataShareTimer: NSTimer!
    
    private var fontSizeChangeObserver: NSObjectProtocol!
    
    private lazy var fetchedResultsController: NSFetchedResultsController! = {
        let request = NSFetchRequest(entityName: kJobEntity)
        request.sortDescriptors = [NSSortDescriptor(key: kJobOrderAttribute, ascending: true)]
        
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
        
        title = NSLocalizedString("titleJobViewController", value: "Jobs", comment: "Title on navigation bar")
        
        let addJobButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addJob:")
        let editButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Organize, target: self, action: "toggleEditMode:")
        let deleteAllButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "deleteAll:")
        
        let sortDownButton = UIBarButtonItem(title: "▽", style: .Plain, target: self, action: "sortByPercentDescending:")
        let sortUpButton = UIBarButtonItem(title: "△", style: .Plain, target: self, action: "sortByPercentAscending:")
        
        
        navigationItem.setLeftBarButtonItems([sortDownButton, sortUpButton], animated: true)
        navigationItem.setRightBarButtonItems([addJobButton, editButton, deleteAllButton], animated: true)
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fontSizeChangeObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIContentSizeCategoryDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
            [weak self] (notification) -> Void in
                self?.tableView.reloadData()
        }
        
        DataShare.deleteAllCommands()
        dataShareTimer?.invalidate()
        dataShareTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "checkDataShareForAvailableCommand", userInfo: nil, repeats: true)
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(fontSizeChangeObserver)
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
    
    func sortByPercentDescending(sender: UIBarButtonItem) {
        Job.sortByPercent(ascending: false)
    }
    
    func sortByPercentAscending(sender: UIBarButtonItem) {
        Job.sortByPercent(ascending: true)
    }
    
    func addJob(sender: UIBarButtonItem) {
        let title = NSLocalizedString("titleCreateJobDialog", value: "Create new Job", comment: "title in alertContoller")
        let placeholder = NSLocalizedString("placeholderCreateJobDialog", value: "Job", comment: "placeholder for input textField")
        let message = NSLocalizedString("messageCreateJobDialog", value: "Type in or dictate a jobname.\nPress \'Add\' to save and continue adding new jobs.\nPress \'Cancel\' if you have complete yout list for now.", comment: "message in alertController")
        let defaultLabel = NSLocalizedString("defaultButtonCreateJobDialog", value: "Add", comment: "default button label text")
        let cancelLabel = NSLocalizedString("cancelButtonCreateJobDialog", value: "Cancel", comment: "cancel button label text")
        
        let dialog = PPHelper.singleTextFieldDialogWithTitle(title, message: message, placeholder: placeholder, textFieldValue: "", defaultLabel: defaultLabel, cancelLabel: cancelLabel) { [weak self] (text) -> Void in
            Job.createJobWithName(text)
            PPHelper.delayOnMainQueue(0.3) { self!.addJob(sender) }
        }
        
        presentViewController(dialog, animated: true, completion: nil)
    }
    
    func toggleEditMode(sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.editing, animated: true)
        sender.tintColor = tableView.editing ? UIColor.redColor() : self.view.tintColor
    }
    
    func deleteAll(sender: UIBarButtonItem) {
        let title = NSLocalizedString("titleDeleteAllJobDialog", value: "Delete All Jobs", comment: "title in alertContoller")
        let message = NSLocalizedString("messageDeleteAllJobDialog", value: "Do you really want to delete ALL jobs?", comment: "message in alertController")
        let defaultLabel = NSLocalizedString("defaultButtonDeleteAllJobDialog", value: "Yes, delete ALL jobs", comment: "default button label text")
        let cancelLabel = NSLocalizedString("cancelButtonDeleteAllJobDialog", value: "Cancel", comment: "cancel button label text")
        
        let dialog = PPHelper.dialogWithTitle(title, message: message, defaultLabel: defaultLabel, cancelLabel: cancelLabel) { Job.deleteAll() }
        
        presentViewController(dialog, animated: true, completion: nil)
    }
    
    // MARK: - Segue Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kTaskTableViewController {
            if let indexPath = tableView.indexPathForSelectedRow, job = fetchedResultsController.objectAtIndexPath(indexPath) as? Job {
            let destinationVC = segue.destinationViewController as? TaskTableViewController
            destinationVC?.job = job
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kJobTableViewCell, forIndexPath: indexPath) as! JobTableViewCell
        
        cell.job = fetchedResultsController.objectAtIndexPath(indexPath) as! Job
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            guard let job = fetchedResultsController.objectAtIndexPath(indexPath) as? Job else { return }
            job.delete()
        }
    }
    
    override func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        guard let jobCell = tableView.cellForRowAtIndexPath(indexPath) as? JobTableViewCell else { return }
        jobCell.interactionAllowed = false
    }

    override func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        guard let jobCell = tableView.cellForRowAtIndexPath(indexPath) as? JobTableViewCell else { return }
        jobCell.interactionAllowed = true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return }
        
        let source = fetchedResultsController.objectAtIndexPath(sourceIndexPath) as! NSManagedObject
        let destination = fetchedResultsController.objectAtIndexPath(destinationIndexPath) as! NSManagedObject
        
        CoreData.moveEntity(kJobEntity, orderAtribute: kJobOrderAttribute, source: source, toDestination: destination)
    }
    
}
