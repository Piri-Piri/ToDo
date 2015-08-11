//
//  Task.swift
//  ToDo
//
//  Created by David Pirih on 20.06.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import Foundation
import CoreData

class Task: NSManagedObject {

    static func createTaskForJob(job: Job, withName name: String) -> Task {
        let task = NSEntityDescription.insertNewObjectForEntityForName(kTaskEntity, inManagedObjectContext: CoreData.sharedInstance.managedObjectContext) as! Task
        
        task.job = job
        task.name = name
        task.completed = false
        task.order = CoreData.minIntegerValueForEntityName(kTaskEntity, attributeName: kTaskOrderAttribute, predicate: NSPredicate(format: "job == %@", job)) - 1
        
        CoreData.sharedInstance.saveContext()
        return task
    }
    
    func delete() {
        CoreData.sharedInstance.managedObjectContext.deleteObject(self)
        CoreData.sharedInstance.saveContext()
    }
    
    func switchCompleted() {
        completed = !completed!.boolValue
        if completed!.boolValue {
            order = CoreData.maxIntegerValueForEntityName(kTaskEntity, attributeName: kTaskOrderAttribute, predicate: NSPredicate(format: "job == %@", job!)) + 1
        } else {
            order = CoreData.minIntegerValueForEntityName(kTaskEntity, attributeName: kTaskOrderAttribute, predicate: NSPredicate(format: "job == %@", job!)) - 1
        }
        CoreData.sharedInstance.saveContext()
    }

}
