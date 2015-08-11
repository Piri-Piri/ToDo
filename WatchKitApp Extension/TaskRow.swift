//
//  TaskRow.swift
//  ToDo
//
//  Created by David Pirih on 27.07.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import UIKit
import WatchKit

class TaskRow: NSObject {

    var task: Task! {
        didSet {
            taskNameLabel.setText(task.name)
            completeCheck.setBackgroundImage(PPCheckmarkCircle.checkCircle(task.completed!.boolValue, radius: 15.0, lineWidth: 4.0))
        }
    }
    
    @IBOutlet var taskNameLabel: WKInterfaceLabel!
    @IBOutlet var completeCheck: WKInterfaceButton!
    
    @IBAction func completeTaskAction() {
        if let existingTask = CoreData.managedObjectForUri(task.objectID.URIRepresentation()) as? Task {
            existingTask.switchCompleted()
            task = existingTask
            
            // notify phone app about a data change
            DataShare.addCommand(kWatchChangedData)
            
            // force task table reload (to show correct order)
            // by simulate a data change inside the phone app
            DataShare.addCommand(kPhoneChangedData)
        }
    }
}
