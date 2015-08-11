//
//  TaskDetailController.swift
//  ToDo
//
//  Created by David Pirih on 29.07.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import WatchKit
import Foundation

class TaskDetailControllerContext {
    var task: Task!
}

class TaskDetailController: WKInterfaceController {

    private var dataShareTimer: NSTimer!
    
    @IBOutlet var taskNameTitleLabel: WKInterfaceLabel!
    @IBOutlet var stateTitleLabel: WKInterfaceLabel!
    
    @IBOutlet var taskNameLabel: WKInterfaceLabel!
    @IBOutlet var stateButton: WKInterfaceButton!
    
    var task: Task! {
        didSet {
            taskNameLabel.setText(task.name)
            stateButton.setBackgroundImage(PPCheckmarkCircle.checkCircle(task.completed!.boolValue, radius: WKInterfaceDevice.currentDevice().screenBounds.size.width / 2.0, lineWidth: 4.0))
            
            let completedTitle = NSLocalizedString("chartButtonTitle", value: "Completed", comment: "stateButtonTitle in WKInterfaceController")
            let openTitle = NSLocalizedString("chartButtonTitle", value: "Open", comment: "stateButtonTitle in WKInterfaceController")
            stateButton.setTitle(task.completed!.boolValue ? completedTitle : openTitle)
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let context = context as? TaskDetailControllerContext {
            task = context.task
        }
        
        setTitle(NSLocalizedString("TaskDetailControllerTitle", value: "Details", comment: "WKInterfaceController Title"))
        
        taskNameTitleLabel.setText(NSLocalizedString("taskNameTitleLabel", value: "Task:", comment: "Section Title"))
        stateTitleLabel.setText(NSLocalizedString("stateTitleLabel", value: "State:", comment: "Section Title"))
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        dataShareTimer.invalidate()
        dataShareTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "checkDataShareForAvailableCommand", userInfo: nil, repeats: true)
    }

    override func didDeactivate() {
        dataShareTimer.invalidate()
        super.didDeactivate()
    }

    // MARK: - IBActions
    
    @IBAction func stateButtonAction() {
        if let existingTask = CoreData.managedObjectForUri(task.objectID.URIRepresentation()) as? Task {
            existingTask.switchCompleted()
            task = existingTask
            
            // notify phone app about a data change
            DataShare.addCommand(kWatchChangedData)
        }
    }
    
    // MARK: - Helpers
    
    func checkDataShareForAvailableCommand() {
        if DataShare.wasCommandAvailable(kPhoneChangedData) {
            reloadData()
        }
    }
    
    func reloadData() {
        if let existingTask = CoreData.managedObjectForUri(task.objectID.URIRepresentation()) as? Task {
            task = existingTask
        } else {
            popController()
        }
    }
}
