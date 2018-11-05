//
//  EditingTableViewController.swift
//  myTodo
//
//  Created by Marc Hein on 03.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift

class EditingTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    var todoListTableVC: TodoListTableViewController? = nil
    var todoItem: Todo?
    var indexPath: IndexPath?
    var datePickerView: UIDatePicker?
    private var returnKeyHandler: IQKeyboardReturnKeyHandler?

    // MARK:- Outlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dueTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.toolbar.isHidden = true
    }

    func configureView() {
        navigationController?.toolbar.isHidden = true

        returnKeyHandler?.delegate = self
        
        datePickerView = UIDatePicker()
        datePickerView!.datePickerMode = UIDatePicker.Mode.dateAndTime
        dueTextField.inputView = datePickerView
        datePickerView!.addTarget(self, action: #selector(handleDatePicker(sender:)), for: UIControl.Event.valueChanged)
        
        if let todo = todoItem {
            title = "Edit"
            titleTextField.text = todo.title?.description
            if let date = todo.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"
                dueTextField.text = dateFormatter.string(from: date)
                datePickerView?.date = date
            }
            locationTextField.text = todo.location?.description
            descTextField.text = todo.desc?.description
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save edited", style: .done, target: self, action: #selector(self.editExistingEntry))
        } else {
            title = "Add"
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"
            dueTextField.text = dateFormatter.string(from: now)
            datePickerView?.date = now
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(self.insertNewEntry))
        }
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"
        dueTextField.text = dateFormatter.string(from: datePickerView!.date)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return 1
        }
    }
    
    @objc func insertNewEntry() {
        var newTodo = TodoData()
        newTodo.title = titleTextField.text
        newTodo.date = getDueDate()
        newTodo.location = locationTextField.text
        newTodo.desc = descTextField.text
        print("todo to add: \(newTodo)")
        todoListTableVC?.insertNewObject(todoData: newTodo)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func getDueDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"
        guard let date = dateFormatter.date(from: dueTextField.text!) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        return date
    }
    
    @objc func editExistingEntry() {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if let currentObject = managedObjectContext.object(with: (todoItem?.objectID)!) as? Todo {
            currentObject.title = titleTextField.text
            currentObject.date = getDueDate()
            currentObject.location = locationTextField.text
            currentObject.desc = descTextField.text
            
            do {
                try managedObjectContext.save()
                print("saved!")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            

            self.navigationController?.popToRootViewController(animated: true)
            
            return
        }
    }
    
    deinit {
        returnKeyHandler = nil
    }
}
