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
        
        let localizedTaskNamePattern = NSLocalizedString("AutoCreateInitialTask", value: "Task for: %@ (auto-created)", comment: "localized string pattern for initial, auto-created")
        let taskName = String(format: localizedTaskNamePattern, job.name!)
        
        Task.createTaskForJob(job, withName: taskName) // methow will save the context 
        return job
    }
    
    func delete() {
        CoreData.sharedInstance.managedObjectContext.deleteObject(self)
        CoreData.sharedInstance.saveContext()
    }
    
    static func deleteAll() {
        let request = NSFetchRequest(entityName: kJobEntity)
        do {
            let allJobs = try CoreData.sharedInstance.managedObjectContext.executeFetchRequest(request) as! [Job]
            allJobs.map({
                CoreData.sharedInstance.managedObjectContext.deleteObject($0)
            })
            CoreData.sharedInstance.saveContext()
        } catch {
            print(error)
        }
    }
    
    func deleteAllTasks() {
        let request = NSFetchRequest(entityName: kTaskEntity)
        request.predicate = NSPredicate(format: "job == %@", self)
        do {
            let allTasks = try CoreData.sharedInstance.managedObjectContext.executeFetchRequest(request) as! [Task]
            allTasks.map({
                CoreData.sharedInstance.managedObjectContext.deleteObject($0)
            })
            CoreData.sharedInstance.saveContext()
        } catch {
            print(error)
        }
    }
    
    func getProgressAsPercent() -> Double {
        if let tasksCount = tasks?.count, tasksCompleted = tasks?.filteredSetUsingPredicate(NSPredicate(format: "completed == true")) {
            guard tasksCount > 0 else { return 100.0 }
            return Double(tasksCompleted.count) / Double(tasksCount) * 100.0
        }
        return 0.0
    }

    static func sortByPercent(ascending ascending: Bool) {
        let request = NSFetchRequest(entityName: kJobEntity)
        do {
            let allJobs = try CoreData.sharedInstance.managedObjectContext.executeFetchRequest(request) as! [Job]
            let allJobsSorted = ascending ?
                                allJobs.sort { $0.getProgressAsPercent() > $1.getProgressAsPercent() } :
                                allJobs.sort { $0.getProgressAsPercent() < $1.getProgressAsPercent() }
            
            for (index, job) in allJobsSorted.enumerate() {
                job.order = index
            }
            CoreData.sharedInstance.saveContext()
        } catch {
            print(error)
        }
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

