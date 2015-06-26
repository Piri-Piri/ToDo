//
//  JobTableViewCell.swift
//  ToDo
//
//  Created by David Pirih on 21.06.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import UIKit

class JobTableViewCell: UITableViewCell {

    var job: Job! {
        didSet {
            jobNane.setTitle(job.name, forState: .Normal)
        }
    }
    
    @IBOutlet weak var jobNane: UIButton!
    @IBOutlet weak var progressImage: UIImageView!
    
    @IBAction func jobNameAction(sender: AnyObject) {
        
    }
}
