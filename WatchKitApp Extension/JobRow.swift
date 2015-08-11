//
//  JobRow.swift
//  ToDo
//
//  Created by David Pirih on 23.07.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import WatchKit

class JobRow: NSObject {

    var job: Job! {
        didSet {
            jobNameLabel.setText(job.name)
            completeProgress.setBackgroundImage(PPProgressCircle.progessCircleForPercent(job.getProgressAsPercent(), radius: 15.0))
        }
    }
    
    @IBOutlet var jobNameLabel: WKInterfaceLabel!
    @IBOutlet var completeProgress: WKInterfaceButton!
}
