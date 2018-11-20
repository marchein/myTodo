//
//  TodoList+TableView.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import UIKit

import MGSwipeTableCell

// MARK: - TableView
extension TodoListTableViewController {
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
}
