//
//  CoreData.swift
//  ToDo
//
//  Created by David Pirih on 20.06.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import Foundation
import CoreData

private var coreDateSharedInstance = CoreData()
class CoreData {

    // MARK: - Helper 
    
    
    static func managedObjectForUri(uri: NSURL) -> NSManagedObject? {
        // ensure working with non-cached data
        CoreData.sharedInstance.managedObjectContext.reset()
        
        if let objectId = CoreData.sharedInstance.persistentStoreCoordinator.managedObjectIDForURIRepresentation(uri) {
            let managedObject = CoreData.sharedInstance.managedObjectContext.objectWithID(objectId)
            if !managedObject.fault {
                return managedObject
            }
            if let entityName = managedObject.entity.name {
                let request = NSFetchRequest(entityName: entityName)
                request.predicate = NSPredicate(format: "SELF == %@", objectId)
                do {
                    return try CoreData.sharedInstance.managedObjectContext.executeFetchRequest(request).first as? NSManagedObject
                } catch {
                    NSLog("\(error)")
                }
            }
        }
        return nil
    }
    
    static func moveEntity(entityName: String, orderAtribute: String, source: NSManagedObject, toDestination destination: NSManagedObject, predicate: NSPredicate = NSPredicate(value: true)) {
        guard let
            sourceIndex = source.valueForKey(orderAtribute)?.integerValue,
            destinationIndex = destination.valueForKey(orderAtribute)?.integerValue else { return }
        
        let request = NSFetchRequest(entityName: entityName)
        if sourceIndex < destinationIndex {
            request.sortDescriptors = [NSSortDescriptor(key: kJobOrderAttribute, ascending: false)]
            let condition = NSPredicate(format: "\(orderAtribute) > \(sourceIndex) AND \(orderAtribute) <= \(destinationIndex)")
            request.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [condition, predicate])
            do {
                let objects = try CoreData.sharedInstance.managedObjectContext.executeFetchRequest(request) as? [NSManagedObject]
                objects!.map {
                    (object) -> NSManagedObject in
                    object.setValue((object.valueForKey(orderAtribute)?.integerValue)! - 1, forKey: kJobOrderAttribute)
                    return object
                }
            } catch {
            
            }
        } else if sourceIndex > destinationIndex {
            request.sortDescriptors = [NSSortDescriptor(key: kJobOrderAttribute, ascending: true)]
            let condition = NSPredicate(format: "\(orderAtribute) < \(sourceIndex) AND \(orderAtribute) >= \(destinationIndex)")
            request.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [condition, predicate])
            do {
                let objects = try CoreData.sharedInstance.managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]
                objects.map {
                    (object) -> NSManagedObject in
                    object.setValue((object.valueForKey(orderAtribute)?.integerValue)! + 1, forKey: kJobOrderAttribute)
                    return object
                }
            } catch {
                
            }
        }
        
        source.setValue(destinationIndex, forKey: kJobOrderAttribute)
        CoreData.sharedInstance.saveContext()
    }
    
    static func minMaxIntegerValueForEntityName(entityName: String, attributeName: String, minimum: Bool, predicate: NSPredicate = NSPredicate(value: true)) -> Int {
        let request = NSFetchRequest(entityName: entityName)
        request.sortDescriptors = [NSSortDescriptor(key: attributeName, ascending: minimum)]
        request.fetchLimit = 1
        request.predicate = predicate
        do {
            let object = try CoreData.sharedInstance.managedObjectContext.executeFetchRequest(request).first
            return object!.valueForKey(attributeName)?.integerValue ?? 0
        } catch {
            return 0
        }
    }
    
    static func minIntegerValueForEntityName(entityName: String, attributeName: String, predicate: NSPredicate = NSPredicate(value: true)) -> Int {
        return CoreData.minMaxIntegerValueForEntityName(entityName, attributeName: attributeName, minimum: true, predicate: predicate)
    }
    
    static func maxIntegerValueForEntityName(entityName: String, attributeName: String, predicate: NSPredicate = NSPredicate(value: true)) -> Int {
        return CoreData.minMaxIntegerValueForEntityName(entityName, attributeName: attributeName, minimum: false, predicate: predicate)
    }
    
    // MARK: - Singelton
    
    class var sharedInstance: CoreData {
        return coreDateSharedInstance
    }
    
    private init () {}
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "de.piri-piri.ToDo" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("ToDo", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)

        /*
        if let containerURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(kAppGroup) {
            let url = containerURL.URLByAppendingPathComponent("ToDoCoreData.sqlite")
        */
            let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ToDoCoreData.sqlite")
        
            var failureReason = "There was an error creating or loading the application's saved data."
            do {
                try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            } catch {
                // Report any error we got.
                var dict = [String: AnyObject]()
                dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
                dict[NSLocalizedFailureReasonErrorKey] = failureReason
                
                dict[NSUnderlyingErrorKey] = error as NSError
                let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
                // Replace this with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
                abort()
            }
        /*
        } else {
            NSLog("Unresolved error: ApplicationGroup \(kAppGroup) not avaiable.")
            abort()
        }
        */
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}

