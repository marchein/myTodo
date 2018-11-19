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

    var managedObjectContext: NSManagedObjectContext? = nil
    var _fetchedResultsController: NSFetchedResultsController<Todo>? = nil
    var todoDetailVC: TodoDetailTableViewController? = nil
    var showConfirmDialog: Bool?
    var emptyViewIsLoaded = false
    let notification = UINotificationFeedbackGenerator()

    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        
        LocalNotification.center.getPendingNotificationRequests { (requests) in
            print("PENDING NOTIFICATIONS: \(requests)")
        }
        
        let appSetup = UserDefaults.standard.bool(forKey: "appSetup")
        if !appSetup {
            print("app will be setup")
            showConfirmDialog = true
            UserDefaults.standard.set(showConfirmDialog, forKey: "showConfirmDialog")
            UserDefaults.standard.set(isSimulatorOrTestFlight(), forKey: "hasTipped")
            UserDefaults.standard.set("default", forKey: "currentIcon")
            UserDefaults.standard.set(true, forKey: "appSetup")
        }
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            todoDetailVC = (controllers[controllers.count-1] as! UINavigationController).topViewController as? TodoDetailTableViewController
        }
        
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.toolbar.isHidden = false
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        configureView()
        super.viewWillAppear(animated)
    }
    
    fileprivate func configureView() {
        self.splitViewController?.preferredDisplayMode = .allVisible
        navigationItem.setLeftBarButtonItems([settingsButton, editButton], animated: true)
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing {
            editButton?.image = #imageLiteral(resourceName: "Edit Done")
        } else {
            editButton?.image = #imageLiteral(resourceName: "Edit")
        }
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? TodoDetailTableViewController else { return false }
        if topAsDetailController.todo == nil {
            return true
        }
        return false
    }
    
    func insertNewObject(todoData: TodoData) {
        let context = self.fetchedResultsController.managedObjectContext
        let newTodo = Todo(context: context)
        newTodo.date = todoData.date!
        newTodo.title = todoData.title!
        newTodo.desc = todoData.desc ?? ""
        newTodo.done = false
        newTodo.location = todoData.location ?? ""
        
        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let todoFromCoreData = fetchedResultsController.object(at: indexPath)
                guard let todoDetailVC = (segue.destination as? UINavigationController)?.topViewController as? TodoDetailTableViewController else {
                    fatalError("Wrong segue identifier for given destination")
                }
                emptyViewIsLoaded = false
                todoDetailVC.todo = todoFromCoreData
                todoDetailVC.indexPath = indexPath
                todoDetailVC.todoListTableVC = self
                todoDetailVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                todoDetailVC.navigationItem.leftItemsSupplementBackButton = true
                
            } else {
                showEmptyView()
            }
        } else if segue.identifier == "addSegue" {
            guard let addVC = segue.destination as? EditingTableViewController else {
                fatalError("Wrong segue identifier for given destination")
            }
            addVC.todoListTableVC = self
        } else if segue.identifier == "quickEditSegue" {
            if let indexPath = tableView.indexPath(for: sender as! MGSwipeTableCell) {
                guard let editVC = segue.destination as? EditingTableViewController else {
                    fatalError("Wrong segue identifier for given destination")
                }
                let todoFromCoreData = fetchedResultsController.object(at: indexPath)
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
            notification.notificationOccurred(.warning)
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            if self.splitViewController?.viewControllers.count == 2 {
                self.performSegue(withIdentifier: "showDetail", sender: self)
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
            
            cell.detailTextLabel?.text = "\(dateValue) \(NSLocalizedString("at", comment: "")) \(timeValue) \(NSLocalizedString("time unit", comment: "at... __UHR__"))"
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
        let context = self.fetchedResultsController.managedObjectContext

        if let currentObject = context.object(with: (selectedItem?.objectID)!) as? Todo {
            currentObject.done = !currentObject.done
        
            if currentObject.done {
                LocalNotification.removeNotification(for: currentObject)
            } else {
                LocalNotification.dispatchlocalNotification(with: currentObject)
            }
            
            do {
                try context.save()
            } catch let error as NSError  {
                fatalError("Could not save \(error), \(error.userInfo)")
            }
            showConfirmDialog = UserDefaults.standard.bool(forKey: "showConfirmDialog")
            if showConfirmDialog ?? true {
                let alert = UIAlertController(title: currentObject.title ?? "myTodo",
                                              message: currentObject.done ? NSLocalizedString("marked_done", comment: "") : NSLocalizedString("marked_undone", comment: ""),
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("Got it", comment: ""), style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
            }
        }
        
        tableView.reloadData()
        notification.notificationOccurred(.success)
    }
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
    
    fileprivate func showEmptyView() {
        // show empty view if list is empty
        if tableView.visibleCells.isEmpty  {
            if let splitNavVC = splitViewController?.viewControllers[1] as? UINavigationController {
                splitNavVC.performSegue(withIdentifier: "emptyDetail", sender: self)
                emptyViewIsLoaded = true
            }
        }
    }
}

extension TodoListTableViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
}
