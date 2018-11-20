//
//  TodoListTableViewController+FRC.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import CoreData
import UIKit

var _fetchedResultsController: NSFetchedResultsController<Todo>? = nil

extension TodoListTableViewController: NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController: NSFetchedResultsController<Todo> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        
        fetchRequest.fetchBatchSize = 20
        
        let doneSortDescriptor = NSSortDescriptor(key: "done", ascending: true)
        let dateSort = NSSortDescriptor(key: "date", ascending: true)
        
        fetchRequest.sortDescriptors = [doneSortDescriptor, dateSort]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "done", cacheName: nil)
        
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, withTodo: anObject as! Todo)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)!, withTodo: anObject as! Todo)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func showEmptyView() {
        // show empty view if list is empty
        if tableView.visibleCells.isEmpty  {
            if let splitNavVC = splitViewController?.viewControllers[1] as? UINavigationController {
                splitNavVC.performSegue(withIdentifier: "emptyDetail", sender: self)
                emptyViewIsLoaded = true
            }
        }
    }
}
