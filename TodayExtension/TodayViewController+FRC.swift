//
//  TodayViewController+FRC.swift
//  TodayExtension
//
//  Created by Marc Hein on 18.10.19.
//  Copyright © 2019 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/*var _fetchedResultsController: NSFetchedResultsController<Todo>? = nil

extension TodayViewController: NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController: NSFetchedResultsController<Todo> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        
        fetchRequest.fetchBatchSize = 20
        
        let doneSortDescriptor = NSSortDescriptor(key: "done", ascending: true)
        let dateSort = NSSortDescriptor(key: "date", ascending: true)
        
        fetchRequest.sortDescriptors = [doneSortDescriptor, dateSort]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: "done", cacheName: nil)
        
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    func refetch() {
       
        
    }
    
}
*/
