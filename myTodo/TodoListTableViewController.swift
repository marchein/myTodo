//
//  MasterViewController.swift
//  myTodo
//
//  Created by Marc Hein on 29.10.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit
import CoreData
import MGSwipeTableCell

class TodoListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var managedObjectContext: NSManagedObjectContext? = nil
    
    enum DateOptions {
        case date
        case time
        case both
    }

    override func viewDidLoad() {
        super.viewDidLoad()
            
        configureView()
    }

    override func viewDidAppear(_ animated: Bool) {
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
            let context = self.fetchedResultsController.managedObjectContext
            let newTodo = Todo(context: context)
            
            newTodo.date = todoData.date!
            newTodo.title = todoData.title!
            newTodo.desc = todoData.desc!
            newTodo.done = false
            newTodo.location = todoData.location!
            
            do {
                try context.save()
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
                print(indexPath)
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
                print(todoFromCoreData)
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
        let array = ["Still to be done", "Already done"]
        
        return array[section]
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
        let doneTableButton = MGSwipeButton(title: todo.done ? "Undone" : "Done", icon: nil, backgroundColor: self.view.tintColor) {
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
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
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
    
        if let _ = todo.date {
            guard let date = getDateOf(date: todo.date, option: .date) else { return }
            guard let time = getDateOf(date: todo.date, option: .time) else { return }
            
            cell.detailTextLabel?.text = "\(date) um \(time) Uhr"
        }
    }
    
    func doneAction(selectedItem: Todo?) {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if let currentObject = managedObjectContext.object(with: (selectedItem?.objectID)!) as? Todo {
            currentObject.done = !currentObject.done
            
            do {
                try managedObjectContext.save()
                print("saved!")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }

    // MARK: - Fetched results controller

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
    var _fetchedResultsController: NSFetchedResultsController<Todo>? = nil

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
    
    @IBAction func generateTestData(_ sender: Any) {
        print("TestData")
        let data = TodoData(title: "Test", date: Date(), location: "Trier", desc: "Lorem ipsum")
        var i = 0
        while (i < 10) {
            insertNewObject(todoData: data)
            i += 1
        }
    }
    
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
    
}

struct TodoData {
    var title: String?
    var date: Date?
    var location: String?
    var desc: String?
}
