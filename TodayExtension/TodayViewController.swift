//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Marc Hein on 18.10.19.
//  Copyright © 2019 Marc Hein Webdesign. All rights reserved.
//

import UIKit
import CoreData
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var todoTitle: UILabel!
    @IBOutlet weak var todoDate: UILabel!
    @IBOutlet weak var todoLocation: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .compact        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let todo = retrieveTodo() {
            todoTitle.text = todo.title
            todoDate.text = getDateOf(date: todo.date, option: .both)
            todoLocation.text = todo.location
        }
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func retrieveTodo() -> Todo? {
        let managedContext = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        
        fetchRequest.fetchBatchSize = 20
        
        let doneSortDescriptor = NSSortDescriptor(key: "done", ascending: true)
        let dateSort = NSSortDescriptor(key: "date", ascending: true)
        
        fetchRequest.sortDescriptors = [doneSortDescriptor, dateSort]
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for todo in result {
                if !todo.done {
                    return todo
                }
            }
        } catch  {
           let nserror = error as NSError
           fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
       }
        return nil
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = PersistentContainer(name: "myTodo") // using the persistent container in Model folder
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    
}
