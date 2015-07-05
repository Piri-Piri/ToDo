//
//  JobTableViewCell.swift
//  ToDo
//
//  Created by David Pirih on 21.06.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import UIKit

class JobTableViewCell: UITableViewCell {
    
    var interactionAllowed: Bool = true {
        didSet {
            jobNane.enabled = interactionAllowed
        }
    }
    
    var job: Job! {
        didSet {
            jobNane.setTitle(job.name, forState: .Normal)
        }
    }
    
    @IBOutlet weak var jobNane: UIButton!
    @IBOutlet weak var progressImage: UIImageView!
    
    @IBAction func jobNameAction(sender: AnyObject) {
        editJob(job)
    }
    
    func editJob(job: Job) {
        let title = NSLocalizedString("titleEditJobDialog", tableName: nil, bundle: NSBundle.mainBundle(), value: "Edit Job", comment: "title in alertContoller")
        let placeholder = NSLocalizedString("placeholderEditJobDialog", tableName: nil, bundle: NSBundle.mainBundle(), value: "Job", comment: "placeholder for input textField")
        let message = NSLocalizedString("messageEditJobDialog", tableName: nil, bundle: NSBundle.mainBundle(), value: "Change jobname", comment: "message in alertController")
        let defaultLabel = NSLocalizedString("defaultButtonEditJobDialog", tableName: nil, bundle: NSBundle.mainBundle(), value: "Edit", comment: "default button label text")
        let cancelLabel = NSLocalizedString("cancelButtonEditJobDialog", tableName: nil, bundle: NSBundle.mainBundle(), value: "Cancel", comment: "cancel button label text")
        
        let dialog = PPHelper.singleTextFieldDialogWithTitle(title, message: message, placeholder: placeholder, textFieldValue: job.name!, defaultLabel: defaultLabel, cancelLabel: cancelLabel) { (text) -> Void in
            job.name = text
            CoreData.sharedInstance.saveContext()
        }
        viewController?.presentViewController(dialog, animated: true, completion: nil)
    }
}
