//
//  JobDetailController.swift
//  ToDo
//
//  Created by David Pirih on 29.07.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import WatchKit
import Foundation


class JobDetailControllerContext {
    var job: Job!
}

class JobDetailController: WKInterfaceController {

    private var dataShareTimer: NSTimer!
    
    @IBOutlet var jobNameTitleLabel: WKInterfaceLabel!
    @IBOutlet var taskTitleLabel: WKInterfaceLabel!
    @IBOutlet var chartTitleLabel: WKInterfaceLabel!
    
    @IBOutlet var quantityTitleLabel: WKInterfaceLabel!
    @IBOutlet var openTitleLabel: WKInterfaceLabel!
    @IBOutlet var completedTitleLabel: WKInterfaceLabel!
    
    @IBOutlet var jobNameLabel: WKInterfaceLabel!
    @IBOutlet var quantityValueLabel: WKInterfaceLabel!
    @IBOutlet var openValueLabel: WKInterfaceLabel!
    @IBOutlet var completedValueLabel: WKInterfaceLabel!
    @IBOutlet var chartButton: WKInterfaceButton!
    
    var job: Job! {
        didSet {
            jobNameLabel.setText("\(job.name)")
            
            let tasksCount = job.tasks?.count ?? 0
            quantityValueLabel.setText("\(tasksCount)")
            
            let tasksCompletedCount = job.tasks?.filteredSetUsingPredicate(NSPredicate(format: "completed == true")).count ?? 0
            completedValueLabel.setText("\(tasksCompletedCount)")
            
            openValueLabel.setText("\(tasksCount - tasksCompletedCount)")
            
            chartButton.setBackgroundImage(PPProgressCircle.progessCircleForPercent(job.getProgressAsPercent(), radius: WKInterfaceDevice.currentDevice().screenBounds.size.width / 2.0, lineWidth: 3.0))
            
            let chartButtonTitle = String(format: "%.1f %% %@", job.getProgressAsPercent(), NSLocalizedString("chartButtonTitle", value: "Completed", comment: "chartButtonTitle in WKInterfaceController"))
            chartButton.setTitle(chartButtonTitle)
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let context = context as? JobDetailControllerContext {
            job = context.job
        }
        
        setTitle(NSLocalizedString("JobDetailControllerTitle", value: "Details", comment: "WKInterfaceController Title"))
        
        jobNameTitleLabel.setText(NSLocalizedString("jobNameTitleLabel", value: "Job:", comment: "Section Title"))
        taskTitleLabel.setText(NSLocalizedString("taskTitleLabel", value: "Tasks:", comment: "Section Title"))
        chartTitleLabel.setText(NSLocalizedString("taskTitleLabel", value: "Chart:", comment: "Section Title"))
        
        quantityTitleLabel.setText(NSLocalizedString("quantityTitleLabel", value: "Quantity", comment: "Value Label"))
        openTitleLabel.setText(NSLocalizedString("openTitleLabel", value: "Open", comment: "Value Label"))
        completedTitleLabel.setText(NSLocalizedString("completedTitleLabel", value: "Completed:", comment: "Value Label"))
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        dataShareTimer.invalidate()
        dataShareTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "checkDataShareForAvailableCommand", userInfo: nil, repeats: true)
        reloadData()
    }

    override func didDeactivate() {
        dataShareTimer.invalidate()
        super.didDeactivate()
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
        if segueIdentifier == kTaskController {
            let context = TaskControllerContext()
            context.job = job
            return context
        }
        return nil
    }
    
    // MARK: - Helpers
    
    func checkDataShareForAvailableCommand() {
        if DataShare.wasCommandAvailable(kPhoneChangedData) {
            reloadData()
        }
    }
    
    func reloadData() {
        if let existingJob = CoreData.managedObjectForUri(job.objectID.URIRepresentation()) as? Job {
            job = existingJob
        } else {
            popController()
        }
    }

}
