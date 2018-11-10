//
//  MasterViewController.swift
//  myTodo
//
//  Created by Marc Hein on 29.10.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import MGSwipeTableCell

class TodoListTableViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext =  (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var _fetchedResultsController: NSFetchedResultsController<Todo>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        
        LocalNotification.center.getPendingNotificationRequests { (requests) in
            print(requests)
        }
        
        configureView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reconfigureView()
    }
    
    fileprivate func configureView() {
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    fileprivate func reconfigureView() {
        navigationController?.toolbar.isHidden = true
    }
    
    func insertNewObject(todoData: TodoData) {
        DispatchQueue.main.async(execute: { () -> Void in
            let newTodo = Todo(context: self.managedObjectContext)
            newTodo.date = todoData.date!
            newTodo.title = todoData.title!
            newTodo.desc = todoData.desc!
            newTodo.done = false
            newTodo.location = todoData.location!
            
            do {
                try self.managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        })
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let todoFromCoreData = fetchedResultsController.object(at: indexPath)
                guard let todoDetailVC = segue.destination as? TodoDetailTableViewController else {
                    fatalError("Wrong segue identifier for given destination")
                }
                todoDetailVC.todo = todoFromCoreData
                todoDetailVC.indexPath = indexPath
                todoDetailVC.todoListTableVC = self
            }
        } else if segue.identifier == "addSegue" {
            guard let addVC = segue.destination as? EditingTableViewController else {
                fatalError("Wrong segue identifier for given destination")
            }
            addVC.todoListTableVC = self
        } else if segue.identifier == "quickEditSegue" {
            if let indexPath = tableView.indexPath(for: sender as! MGSwipeTableCell) {
                let todoFromCoreData = fetchedResultsController.object(at: indexPath)
                guard let editVC = segue.destination as? EditingTableViewController else {
                    fatalError("Wrong segue identifier for given destination")
                }
                editVC.todoItem = todoFromCoreData
                editVC.indexPath = indexPath
                tableView.setEditing(false, animated: false)
            }
        }
    }

    // MARK: - Table View

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let numberOfSections = tableView.numberOfSections
        let sectionNames = [NSLocalizedString("Left to do", comment: ""),  NSLocalizedString("Done", comment: "")]
        if numberOfSections == 1 {
            return nil
        } else {
            return sectionNames[section]

        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as! MGSwipeTableCell
        let todo = fetchedResultsController.object(at: indexPath)
        let doneTableButton = MGSwipeButton(title: todo.done ? NSLocalizedString("Undone", comment: "") : NSLocalizedString("Done", comment: ""), icon: nil, backgroundColor: self.view.tintColor) {
            (sender: MGSwipeTableCell!) -> Bool in
            self.doneAction(selectedItem: todo)
            return true
        }
        cell.leftButtons = [doneTableButton]

        let leftExpansionSettings = MGSwipeExpansionSettings()
        leftExpansionSettings.fillOnTrigger = true
        leftExpansionSettings.buttonIndex = 0
        leftExpansionSettings.threshold = 1
        cell.leftExpansion = leftExpansionSettings
        cell.leftSwipeSettings.transition = .drag
        
        configureCell(cell, withTodo: todo)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            managedObjectContext.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func configureCell(_ cell: UITableViewCell, withTodo todo: Todo) {
        if let title = todo.title {
            cell.textLabel!.text = title.description
        }
    
        if let date = todo.date {
            guard let dateValue = getDateOf(date: date, option: .date) else { return }
            guard let timeValue = getDateOf(date: date, option: .time) else { return }
            
            cell.detailTextLabel?.text = "\(dateValue) \(NSLocalizedString("at", comment: "")) \(timeValue) \(NSLocalizedString(".", comment: "at... __UHR__"))"
        }
        
        if todo.done {
            cell.textLabel?.textColor = UIColor.lightGray
            cell.detailTextLabel?.textColor = UIColor.lightGray
        } else {
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        }
    }
    
    func doneAction(selectedItem: Todo?) {
        if let currentObject = managedObjectContext.object(with: (selectedItem?.objectID)!) as? Todo {
            currentObject.done = !currentObject.done
        
            if currentObject.done {
                LocalNotification.removeNotification(for: currentObject)
            } else {
                LocalNotification.dispatchlocalNotification(with: currentObject)
            }
            
            do {
                try managedObjectContext.save()
            } catch let error as NSError  {
                fatalError("Could not save \(error), \(error.userInfo)")
            }
            
            let alert = UIAlertController(title: "myTodo", message: currentObject.done ? NSLocalizedString("Todo as been marked as done.", comment: "") : NSLocalizedString("Todo has been marked as undone.", comment: ""), preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Got it", comment: ""), style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
        
        tableView.reloadData()
    }
}

// MARK:- Date functions
func getDateOf(date: Date?, option: DateOptions) -> String? {
    guard let date = date else { return nil }
    let formatter = DateFormatter()
    if option == .date {
        formatter.dateFormat = "dd.MM.yyyy"
    } else if option == .time {
        formatter.dateFormat = "HH:mm"
    } else if option == .both {
        formatter.dateFormat = "dd.MM.yyyy - HH:mm"
    }
    return  formatter.string(from: date)
}

enum DateOptions {
    case date
    case time
    case both
}

// MARK:- Extensions

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
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "done", cacheName: nil)
        
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
}

extension TodoListTableViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
}
