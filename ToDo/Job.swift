//
//  Job.swift
//  ToDo
//
//  Created by David Pirih on 20.06.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import Foundation
import CoreData

class Job: NSManagedObject {

    static func createJobWithName(name: String) -> Job {
        let job = NSEntityDescription.insertNewObjectForEntityForName(kJobEntity, inManagedObjectContext: CoreData.sharedInstance.managedObjectContext) as! Job
        
        job.name = name
        
        CoreData.sharedInstance.saveContext()
        
        return job
    }
    
    func delete() {
        CoreData.sharedInstance.managedObjectContext.deleteObject(self)
        CoreData.sharedInstance.saveContext()
    }

}

