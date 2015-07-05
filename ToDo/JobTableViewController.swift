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
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            case .Move:
                tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
            case .Update:
                tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}

class JobTableViewController: UITableViewController {

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

        title = NSLocalizedString("titleJobViewController", tableName: nil, bundle: NSBundle.mainBundle(), value: "Jobs", comment: "Title on navigation bar")
        
        let addJobButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addJob:")
        navigationItem.setRightBarButtonItem(addJobButton, animated: true)
    }

    // MARK: - BarButtonItem actions
    
    func addJob(sender: UIBarButtonItem) {
        let title = NSLocalizedString("titleCreateJobDialog", tableName: nil, bundle: NSBundle.mainBundle(), value: "Create new Job", comment: "title in alertContoller")
        let placeholder = NSLocalizedString("placeholderCreateJobDialog", tableName: nil, bundle: NSBundle.mainBundle(), value: "Job", comment: "placeholder for input textField")
        let message = NSLocalizedString("messageCreateJobDialog", tableName: nil, bundle: NSBundle.mainBundle(), value: "Type in or dictate a jobname. Press 'Add' to save and contuine adding new jobs. Press 'Cancel' if you have complete yout list for now.", comment: "message in alertController")
        let defaultLabel = NSLocalizedString("defaultButtonCreateJobDialog", tableName: nil, bundle: NSBundle.mainBundle(), value: "Add", comment: "default button label text")
        let cancelLabel = NSLocalizedString("cancelButtonCreateJobDialog", tableName: nil, bundle: NSBundle.mainBundle(), value: "Cancel", comment: "cancel button label text")
        
        let dialog = PPHelper.singleTextFieldDialogWithTitle(title, message: message, placeholder: placeholder, textFieldValue: "", defaultLabel: defaultLabel, cancelLabel: cancelLabel) { [weak self] (text) -> Void in
            Job.createJobWithName(text)
            PPHelper.delayOnMainQueue(0.3) { () -> Void in
                self!.addJob(sender)
            }
        }
        
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
    
}
