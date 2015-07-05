//
//  PPHelper.swift
//  ToDo
//
//  Created by David Pirih on 05.07.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import Foundation
import UIKit

class PPHelper {
    
    static func delayOnMainQueue(delay: NSTimeInterval, closure: () -> Void ) {
        self.delayOnQueue(delay, queue: dispatch_get_main_queue(), closure: closure)
    }
    
    static func delayOnQueue(delay: NSTimeInterval, queue: dispatch_queue_t, closure: () -> Void ) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, queue, closure)
        
    }
    
    static func singleTextFieldDialogWithTitle(title: String, message: String, placeholder: String, textFieldValue: String, defaultLabel: String, cancelLabel: String, defaultClosure: (text: String) -> Void) -> UIAlertController {
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        controller.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = placeholder
            textField.text = textFieldValue
        }
        
        let defaultAction = UIAlertAction(title: defaultLabel, style: .Default) { (action) -> Void in
            guard let textField = controller.textFields?.first where !textField.text!.isEmpty else { return }
            defaultClosure(text: textField.text!)
        }
        let cancelAction = UIAlertAction(title: cancelLabel, style: .Cancel, handler: nil)
        
        controller.addAction(defaultAction)
        controller.addAction(cancelAction)
        
        return controller
    }
}