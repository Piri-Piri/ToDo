//
//  Job+CoreDataProperties.swift
//  ToDo
//
//  Created by David Pirih on 20.06.15.
//  Copyright © 2015 Piri-Piri. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Job {

    @NSManaged var name: String?
    @NSManaged var order: NSNumber?
    @NSManaged var tasks: NSSet?

}
