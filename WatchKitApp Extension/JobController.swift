//
//  JobController.swift
//  ToDo
//
//  Created by David Pirih on 23.07.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import WatchKit
//import Foundation
import CoreData

class JobController: WKInterfaceController {

    private var dataShareTimer: NSTimer!
    
    @IBOutlet var jobTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        DataShare.deleteAllCommands()
        dataShareTimer?.invalidate()
        dataShareTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "checkDataShareForAvailableCommand", userInfo: nil, repeats: true)
        reloadData()
    }

    override func didDeactivate() {
        dataShareTimer.invalidate()
        super.didDeactivate()
    }
    
    // MARK: - Segue Navigation
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        if let jobRow = jobTable.rowControllerAtIndex(rowIndex) as? JobRow, job = jobRow.job {
            if segueIdentifier == kTaskController {
                let context = TaskControllerContext()
                context.job = job
                return context
            }
            if segueIdentifier == kJobDetailController {
                let context = JobDetailControllerContext()
                context.job = job
                return context
            }
        }
        return nil
    }

    // MARK: - Helpers
    
    func checkDataShareForAvailableCommand() {
        if DataShare.wasCommandAvailable(kPhoneChangedData) {
            // avoid cached data for reload on watch app
            CoreData.sharedInstance.managedObjectContext.reset()
            reloadData()
        }
    }
    
    func reloadData() {
        let request = NSFetchRequest(entityName: kJobEntity)
        request.sortDescriptors = [NSSortDescriptor(key: kJobOrderAttribute, ascending: true)]
        
        do {
            let allJobs = try CoreData.sharedInstance.managedObjectContext.executeFetchRequest(request)

            jobTable.setNumberOfRows(allJobs.count, withRowType: kJobRow)
            for (index, job) in allJobs.enumerate() {
                if let jobRow = jobTable.rowControllerAtIndex(index) as? JobRow {
                    jobRow.job = job as! Job
                }
            }
        } catch {
            NSLog("\(error)")
        }
    }
}
