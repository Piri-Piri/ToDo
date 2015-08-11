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
            jobNane.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            jobNane.setTitle(job.name, forState: .Normal)
            let width = progressImage.bounds.size.width
            progressImage.image = PPProgressCircle.progessCircleForPercent(job.getProgressAsPercent(), radius: width / 2.0, lineWidth: 4.0)
        }
    }
    
    @IBOutlet weak var jobNane: UIButton! {
        didSet {
            jobNane.layer.cornerRadius = 6.0
            jobNane.layer.borderColor = UIColor.lightGrayColor().CGColor
            jobNane.layer.borderWidth = 1.0
            jobNane.layer.backgroundColor = UIColor(white: 0.98, alpha: 1.0).CGColor
            
        }
    }
    
    
    @IBOutlet weak var progressImage: UIImageView!
    
    @IBAction func jobNameAction(sender: AnyObject) {
        editJob(job)
    }
    
    func editJob(job: Job) {
        let title = NSLocalizedString("titleEditJobDialog", value: "Edit Job", comment: "title in alertContoller")
        let placeholder = NSLocalizedString("placeholderEditJobDialog", value: "Job", comment: "placeholder for input textField")
        let message = NSLocalizedString("messageEditJobDialog", value: "Change jobname", comment: "message in alertController")
        let defaultLabel = NSLocalizedString("defaultButtonEditJobDialog", value: "Edit", comment: "default button label text")
        let cancelLabel = NSLocalizedString("cancelButtonEditJobDialog", value: "Cancel", comment: "cancel button label text")
        
        let dialog = PPHelper.singleTextFieldDialogWithTitle(title, message: message, placeholder: placeholder, textFieldValue: job.name!, defaultLabel: defaultLabel, cancelLabel: cancelLabel) { (text) -> Void in
            job.name = text
            CoreData.sharedInstance.saveContext()
        }
        viewController?.presentViewController(dialog, animated: true, completion: nil)
    }
}
