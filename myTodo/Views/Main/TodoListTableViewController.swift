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

        setupApp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.toolbar.isHidden = false
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        configureView()
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    fileprivate func setupApp() {
        let appSetup = UserDefaults.standard.bool(forKey: localStoreKeys.appSetup)
        
        if !appSetup {
            showConfirmDialog = true
            UserDefaults.standard.set(showConfirmDialog, forKey: localStoreKeys.showConfirmDialog)
            UserDefaults.standard.set(isSimulatorOrTestFlight(), forKey: localStoreKeys.isTester)
            UserDefaults.standard.set(myTodo.defaultAppIcon, forKey: localStoreKeys.currentAppIcon)
            UserDefaults.standard.set(true, forKey: localStoreKeys.appSetup)
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupSplitView()
        configureView()
    }
    
    fileprivate func setupSplitView() {
        if let split = splitViewController {
            let controllers = split.viewControllers
            todoDetailVC = (controllers[controllers.count-1] as! UINavigationController).topViewController as? TodoDetailTableViewController
        }
    }
    
    fileprivate func configureView() {
        self.splitViewController?.preferredDisplayMode = .allVisible
        navigationItem.setLeftBarButtonItems([settingsButton, editButton], animated: true)
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        editButton.image = tableView.isEditing ? #imageLiteral(resourceName: "Edit Done") : #imageLiteral(resourceName: "Edit")
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
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
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
            showConfirmDialog = UserDefaults.standard.bool(forKey: localStoreKeys.showConfirmDialog)
            if showConfirmDialog ?? true {
                let title = currentObject.title ?? "myTodo"
                let message = currentObject.done ? NSLocalizedString("marked_done", comment: "") : NSLocalizedString("marked_undone", comment: "")
                showMessage(title: title, message: message, on: self)
            }
        }
        
        tableView.reloadData()
        notification.notificationOccurred(.success)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == myTodoSegue.showDetail {
            if let todoDetailVC = (segue.destination as? UINavigationController)?.topViewController as? TodoDetailTableViewController {
                prepareShowDetailSegue(todoDetailVC: todoDetailVC)
            }
        } else if segue.identifier == myTodoSegue.addTodo {
            if let addVC = segue.destination as? TodoEditingTableViewController {
                addVC.todoListTableVC = self
            }
        } else if segue.identifier == myTodoSegue.quickEdit {
            if let editVC = segue.destination as? TodoEditingTableViewController {
                let senderCell = sender as! MGSwipeTableCell
                prepareQuickEditSegue(editVC: editVC, cell: senderCell)
            }
        }
    }
    
    func prepareShowDetailSegue(todoDetailVC: TodoDetailTableViewController) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let todoFromCoreData = fetchedResultsController.object(at: indexPath)
        
        emptyViewIsLoaded = false
        todoDetailVC.todo = todoFromCoreData
        todoDetailVC.indexPath = indexPath
        todoDetailVC.todoListTableVC = self
        todoDetailVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        todoDetailVC.navigationItem.leftItemsSupplementBackButton = true
    }
    
    func prepareQuickEditSegue(editVC: TodoEditingTableViewController, cell: MGSwipeTableCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let todoFromCoreData = fetchedResultsController.object(at: indexPath)
        editVC.todoItem = todoFromCoreData
        editVC.indexPath = indexPath
        tableView.setEditing(false, animated: false)
    }
}
