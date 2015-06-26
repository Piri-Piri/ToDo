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

    private var _fetchedResultsController: NSFetchedResultsController!
    private var fetchedResultsController: NSFetchedResultsController! {
        if _fetchedResultsController != nil { return _fetchedResultsController }
        
        let request = NSFetchRequest(entityName: kJobEntity)
        request.sortDescriptors = [NSSortDescriptor(key: kJobOrderAttribute, ascending: true)]
        
        _fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreData.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        _fetchedResultsController.delegate = self
        
        do {
            try _fetchedResultsController.performFetch()
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return _fetchedResultsController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("titleJobViewController", tableName: nil, bundle: NSBundle.mainBundle(), value: "Jobs", comment: "Title on navigation bar")
        
        let addJobButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addJob:")
        navigationItem.setRightBarButtonItem(addJobButton, animated: true)
    }

    // MARK: - BarButtonItem actions
    
    func addJob(job: Job) {
        let dialog = UIAlertController(title: "Jobname", message: "Bitte geben Sie einen Jobnamen ein", preferredStyle: .Alert)
        
        dialog.addTextFieldWithConfigurationHandler { (textfield) -> Void in
            textfield.placeholder = "Jobname"
        }
        
        let cancel = UIAlertAction(title: "Abbrechen", style: .Cancel, handler: nil)
        dialog.addAction(cancel)
        
        let ok = UIAlertAction(title: "Okay", style: .Default) { (action) -> Void in
            if let textField = dialog.textFields?.first where !textField.text!.isEmpty {
                Job.createJobWithName(textField.text!)
            }
        }
        dialog.addAction(ok)
        
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
    
    
}
