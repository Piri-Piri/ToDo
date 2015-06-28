//
//  Job.swift
//  ToDo
//
//  Created by David Pirih on 20.06.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import Foundation
import CoreData

/*
// avoid recursive database trigger loop
private var jobsDidSaveArray = [Job]() 
*/

class Job: NSManagedObject {

    static func createJobWithName(name: String) -> Job {
        let job = NSEntityDescription.insertNewObjectForEntityForName(kJobEntity, inManagedObjectContext: CoreData.sharedInstance.managedObjectContext) as! Job
        
        job.name = name
        job.order = CoreData.minIntegerValueForEntityName(kJobEntity, attributeName: kJobOrderAttribute) - 1
        
        CoreData.sharedInstance.saveContext()
        
        return job
    }
    
    func delete() {
        CoreData.sharedInstance.managedObjectContext.deleteObject(self)
        CoreData.sharedInstance.saveContext()
    }

    /*
    // database trigger with recursive loop protection
    override func willSave() {
        super.willSave()
        
        if let index = jobsDidSaveArray.indexOf(self) {
            jobsDidSaveArray.removeAtIndex(index)
        } else {
            jobsDidSaveArray.append(self)
            if inserted {
                let minValue = CoreData.minIntegerValueForEntityName(kJobEntity, attributeName: kJobOrderAttribute)
                order = minValue - 1
            }
        }
            
    }
    */
}

