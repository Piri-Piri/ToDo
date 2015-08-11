//
//  DataShare.swift
//  ToDo
//
//  Created by David Pirih on 20.06.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//

import Foundation
import CoreData

class DataShare: NSManagedObject {

    static func deleteAllCommands() {
        let request = NSFetchRequest(entityName: kDataShareEntity)
        do {
            let allCommands = try CoreData.sharedInstance.managedObjectContext.executeFetchRequest(request) as! [DataShare]
            allCommands.map({
                CoreData.sharedInstance.managedObjectContext.deleteObject($0)
            })
            CoreData.sharedInstance.saveContext()
        } catch {
            NSLog("\(error)")
        }
    }
    
    static func addCommand(command: String) {
        if let dataShare = NSEntityDescription.insertNewObjectForEntityForName(kDataShareEntity, inManagedObjectContext: CoreData.sharedInstance.managedObjectContext) as? DataShare {
            dataShare.command = command
            CoreData.sharedInstance.saveContext()
        }
    }
    
    static func wasCommandAvailable(command: String) -> Bool {
        let request = NSFetchRequest(entityName: kDataShareEntity)
        do {
            let allAvailableCommands = try CoreData.sharedInstance.managedObjectContext.executeFetchRequest(request) as! [DataShare]
            for availableCommand in allAvailableCommands {
                if availableCommand.command == command {
                    CoreData.sharedInstance.managedObjectContext.deleteObject(availableCommand)
                    CoreData.sharedInstance.saveContext()
                    return true
                }
            }
        } catch {
            NSLog("\(error)")
        }
        return false
    }

}
