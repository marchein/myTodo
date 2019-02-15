//
//  EditingTableViewController.swift
//  myTodo
//
//  Created by Marc Hein on 03.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit
import CoreData

class TodoEditingTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    // MARK:- Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dueTextField: FixedUITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    
    // MARK:- Class Attributes
    var todoListTableVC: TodoListTableViewController?
    var todoItem: Todo?
    var indexPath: IndexPath?
    var datePickerView: UIDatePicker?
    let notification = UINotificationFeedbackGenerator()
    
    // MARK:- System Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    fileprivate func configureView() {
        navigationController?.toolbar.isHidden = true
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        
        setupDatePicker()
        
        if let todo = todoItem {
            setupForEditing(todo: todo)
        } else {
            setupForAdding()
        }
        
        titleTextField.addTarget(self, action: #selector(checkIfSavingIsPossible), for: UIControl.Event.editingChanged)
        dueTextField.addTarget(self, action: #selector(checkIfSavingIsPossible), for: UIControl.Event.editingChanged)
        descTextView.delegate = self

        checkIfSavingIsPossible()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == descTextView {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        checkIfSavingIsPossible()
    }
        
    func setupForEditing(todo: Todo) {
        guard let todoTitle = todo.title else { return }
        guard let todoLocation = todo.location else { return }
        guard let todoDescription = todo.desc else { return }
        title = NSLocalizedString("Edit", comment: "")
        titleTextField.text = todoTitle
        if let date = todo.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"
            dueTextField.text = dateFormatter.string(from: date)
            datePickerView?.date = date
        }
        locationTextField.text = todoLocation
        descTextView.text = todoDescription
        
        let editButton = UIBarButtonItem.init(title: NSLocalizedString("Save", comment: ""), style: .done, target: self, action: #selector(self.editExistingEntry))
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    func setupForAdding() {
        title = NSLocalizedString("Add", comment: "")
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"
        dueTextField.text = dateFormatter.string(from: now)
        datePickerView?.date = now
        let addButton = UIBarButtonItem.init(title: NSLocalizedString("Save", comment: ""), style: .done, target: self, action: #selector(self.insertNewEntry))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    fileprivate func setupDatePicker() {
        datePickerView = UIDatePicker()
        datePickerView!.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePickerView!.locale = Locale.current
        datePickerView?.minuteInterval = 5
        dueTextField.inputView = datePickerView
        datePickerView!.addTarget(self, action: #selector(handleDatePicker(sender:)), for: UIControl.Event.valueChanged)
    }
    
    @objc fileprivate func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"
        dueTextField.text = dateFormatter.string(from: datePickerView!.date)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @objc func checkIfSavingIsPossible() {
        let titleIsEmpty = titleTextField.text?.isEmpty ?? true
        let dateIsEmpty = dueTextField.text?.isEmpty ?? true
        
        let canSave = !titleIsEmpty && !dateIsEmpty
        self.navigationItem.rightBarButtonItem?.isEnabled = canSave
    }
        
    @objc fileprivate func insertNewEntry() {
        let isValid = checkInputFields()
        if isValid {
            notification.notificationOccurred(.success)
            var newTodo = TodoData()
            newTodo.title = titleTextField.text
            newTodo.date = getDueDate()!
            newTodo.location = locationTextField.text
            newTodo.desc = descTextView.text
            todoListTableVC?.insertNewObject(todoData: newTodo)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func getDueDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"
        guard let date = dateFormatter.date(from: dueTextField.text!) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        return date
    }
    
    func checkInputFields() -> Bool {
        var valid = true
        var errorMessage: String = NSLocalizedString("No Error", comment: "")
        
        if titleTextField.text!.count < 1 {
            valid = false
            errorMessage = NSLocalizedString("Title field cannot be empty", comment: "")
        }
        
        if getDueDate() == nil {
            valid = false
            errorMessage = NSLocalizedString("Something seems wrong with your due date field, try again please.", comment: "")
        }
        
        if !valid {
            notification.notificationOccurred(.error)
            let title = NSLocalizedString("Error while saving your to do", comment: "")
            showMessage(title: title, message: errorMessage, on: self)
        }
        return valid
    }
    
    @objc fileprivate func editExistingEntry() {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if let currentTodo = managedObjectContext.object(with: (todoItem?.objectID)!) as? Todo {
            notification.notificationOccurred(.success)

            currentTodo.title = titleTextField.text
            currentTodo.date = getDueDate()
            currentTodo.location = locationTextField.text
            currentTodo.desc = descTextView.text
            
            do {
                try managedObjectContext.save()
                LocalNotification.dispatchlocalNotification(with: currentTodo)
            } catch let error as NSError  {
                fatalError("Could not save \(error), \(error.userInfo)")
            }
            
            self.navigationController?.popViewController(animated: true)
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
