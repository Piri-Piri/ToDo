//
//  TaskTableViewCell.swift
//  ToDo
//
//  Created by David Pirih on 16.07.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    var interactionAllowed: Bool = true {
        didSet {
            taskName.enabled = interactionAllowed
        }
    }
    
    var task: Task! {
        didSet {
            taskName.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            taskName.setTitle(task.name, forState: .Normal)
            let width = completedImage.bounds.size.width
            completedImage.image = PPCheckmarkCircle.checkCircle(task.completed!.boolValue, radius: width / 2.0, lineWidth: 4.0)
        }
    }
    
    @IBOutlet weak var taskName: UIButton! {
        didSet {
            taskName.layer.cornerRadius = 6.0
            taskName.layer.borderColor = UIColor.lightGrayColor().CGColor
            taskName.layer.borderWidth = 1.0
            taskName.layer.backgroundColor = UIColor(white: 0.98, alpha: 1.0).CGColor
            
        }
    }
    
    @IBOutlet weak var completedImage: UIImageView!
    
    @IBAction func taskNameAction(sender: AnyObject) {
        editTask(task)
    }

    func editTask(task: Task) {
        let title = NSLocalizedString("titleEditTaskDialog", value: "Edit Task", comment: "title in alertContoller")
        let placeholder = NSLocalizedString("placeholderEditTaskDialog", value: "Task", comment: "placeholder for input textField")
        let message = NSLocalizedString("messageEditTaskDialog", value: "Change taskname", comment: "message in alertController")
        let defaultLabel = NSLocalizedString("defaultButtonEditTaskDialog", value: "Edit", comment: "default button label text")
        let cancelLabel = NSLocalizedString("cancelButtonEditTaskDialog", value: "Cancel", comment: "cancel button label text")
        
        let dialog = PPHelper.singleTextFieldDialogWithTitle(title, message: message, placeholder: placeholder, textFieldValue: task.name!, defaultLabel: defaultLabel, cancelLabel: cancelLabel) { (text) -> Void in
            task.name = text
            CoreData.sharedInstance.saveContext()
        }
        viewController?.presentViewController(dialog, animated: true, completion: nil)
    }
}
