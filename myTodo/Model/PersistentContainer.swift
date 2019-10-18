//
//  PersistentContainer.swift
//  myTodo
//
//  Created by Marc Hein on 18.10.19.
//  Copyright © 2019 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import CoreData

class PersistentContainer: NSPersistentContainer{
    override class func defaultDirectoryURL() -> URL{
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: myTodo.groupIdentifier)!
    }
 
    override init(name: String, managedObjectModel model: NSManagedObjectModel) {
        super.init(name: name, managedObjectModel: model)
    }
}
