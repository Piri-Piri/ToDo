//
//  TaskController.swift
//  ToDo
//
//  Created by David Pirih on 27.07.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

class TaskControllerContext {
    var job: Job!
}

class TaskController: WKInterfaceController {

    private var dataShareTimer: NSTimer!
    
    private var job: Job! {
        didSet {
            setTitle(job.name)
            reloadData()
        }
    }
    
    @IBOutlet var taskTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        if let context = context as? TaskControllerContext {
            job = context.job
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        dataShareTimer.invalidate()
        dataShareTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "checkDataShareForAvailableCommand", userInfo: nil, repeats: true)
    }

    override func didDeactivate() {
        dataShareTimer?.invalidate()
        super.didDeactivate()
    }
    
    
    // MARK: - Segue Navigation
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        if let taskRow = taskTable.rowControllerAtIndex(rowIndex) as? TaskRow, task = taskRow.task {
            if segueIdentifier == kTaskDetailController {
                let context = TaskDetailControllerContext()
                context.task = task
                return context
            }
        }
        return nil
    }
    
    // MARK: - Helpers
    
    func checkDataShareForAvailableCommand() {
        if DataShare.wasCommandAvailable(kPhoneChangedData) {
            if let _ = CoreData.managedObjectForUri(job.objectID.URIRepresentation()) as? Job {
                reloadData()
            } else {
                popController()
            }
        }
    }
    
    func reloadData() {
        let request = NSFetchRequest(entityName: kTaskEntity)
        request.sortDescriptors = [NSSortDescriptor(key: kTaskOrderAttribute, ascending: true)]
        request.predicate = NSPredicate(format: "job == %@", job)
        do {
            let allTasks = try CoreData.sharedInstance.managedObjectContext.executeFetchRequest(request)
            
            taskTable.setNumberOfRows(allTasks.count, withRowType: kTaskRow)
            for (index, task) in allTasks.enumerate() {
                if let taskRow = taskTable.rowControllerAtIndex(index) as? TaskRow {
                    taskRow.task = task as! Task
                }
            }
        } catch {
            NSLog("\(error)")
        }
    }

}
