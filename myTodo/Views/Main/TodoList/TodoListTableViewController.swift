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

class TodoListTableViewController: UITableViewController, UIViewControllerPreviewingDelegate {

    var managedObjectContext: NSManagedObjectContext? = nil
    var todoDetailVC: TodoDetailTableViewController? = nil
    var showConfirmDialog: Bool?
    var emptyViewIsLoaded = false
    let notification = UINotificationFeedbackGenerator()
    var selectedIndexPath: IndexPath? = nil;
    var selectedTodo: Todo? = nil;

    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
        
        if #available(iOS 13.0, *) {
            let inter = UIContextMenuInteraction(delegate: self)
            self.view.addInteraction(inter)
        }
        
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
            UserDefaults.standard.set(0, forKey: localStoreKeys.todosAdded)
            UserDefaults.standard.set(true, forKey: localStoreKeys.appSetup)
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupSplitView()
        configureView()
    }
    
    fileprivate func setupSplitView() {
        if let split = splitViewController {
            let controllers = split.viewControllers
            self.todoDetailVC = (controllers[controllers.count-1] as! UINavigationController).topViewController as? TodoDetailTableViewController
        }
    }
    
    fileprivate func configureView() {
        self.splitViewController?.preferredDisplayMode = .allVisible
        navigationItem.setLeftBarButtonItems([settingsButton, editButton], animated: true)
    }
    
    @IBAction func editButtonTapped(_ sender: Any?) {
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
        DispatchQueue.global(qos: .background).async {
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

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
        tableView.setEditing(false, animated: true)
        editButton.image = #imageLiteral(resourceName: "Edit")
        
        switch segue.identifier {
        case myTodoSegue.showDetail:
            let todoDetailVC = (segue.destination as! UINavigationController).topViewController as! TodoDetailTableViewController
            prepareShowDetailSegue(todoDetailVC: todoDetailVC)
        case myTodoSegue.addTodo:
            let addVC = segue.destination as! TodoEditingTableViewController
            addVC.todoListTableVC = self
        case myTodoSegue.quickEdit:
            let editVC = segue.destination as! TodoEditingTableViewController
            let senderCell = sender as! MGSwipeTableCell
            prepareQuickEditSegue(editVC: editVC, cell: senderCell)
        case myTodoSegue.about:
            let aboutVC = (segue.destination as! UINavigationController).topViewController as! AboutTableViewController
            aboutVC.todoListTableVC = self
        default:
            return
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
    
    private func viewControllerForTodo(todo: Todo, indexPath: IndexPath) -> UIViewController {
        let todoDetailVC = TodoDetailTableViewController()
        todoDetailVC.todo = todo
        return todoDetailVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            let todoFromCoreData = fetchedResultsController.object(at: indexPath)
            let storyBoard = UIStoryboard(name: "Detail", bundle: nil)
            if let detailNavVC = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as? UINavigationController,
               let detailVC = detailNavVC.viewControllers[0] as? TodoDetailTableViewController {
                detailVC.todo = todoFromCoreData
                detailVC.indexPath = indexPath
                detailVC.todoListTableVC = self
                detailVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                detailVC.navigationItem.leftItemsSupplementBackButton = true
                detailNavVC.setNavigationBarHidden(true, animated: false)
                detailNavVC.setToolbarHidden(true, animated: false)

                detailVC.isPeeking = true
                
                return detailNavVC
            }
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let navVC = navigationController else { fatalError("No main navigation controller defined!") }
        navVC.pushViewController(viewControllerToCommit, animated: true)
    }
}
