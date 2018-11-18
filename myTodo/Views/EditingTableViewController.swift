//
//  EditingTableViewController.swift
//  myTodo
//
//  Created by Marc Hein on 03.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit
import CoreData

class EditingTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
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
    var tbAccessoryView : UIToolbar?
    var maxTag = 0
    var textSubViews: [UIView]?
    
    // MARK:- System Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbar.isHidden = true
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    fileprivate func configureView() {
        navigationController?.toolbar.isHidden = true
        navigationController?.navigationBar.prefersLargeTitles = true
        datePickerView = UIDatePicker()
        datePickerView!.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePickerView!.locale = Locale.current
        datePickerView?.minuteInterval = 5
        dueTextField.inputView = datePickerView
        datePickerView!.addTarget(self, action: #selector(handleDatePicker(sender:)), for: UIControl.Event.valueChanged)
        
        if let todo = todoItem {
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
        } else {
            title = NSLocalizedString("Add", comment: "")
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"
            dueTextField.text = dateFormatter.string(from: now)
            datePickerView?.date = now
            let addButton = UIBarButtonItem.init(title: NSLocalizedString("Save", comment: ""), style: .done, target: self, action: #selector(self.insertNewEntry))
            self.navigationItem.rightBarButtonItem = addButton
        }
        titleTextField.addTarget(self, action: #selector(checkIfSavingIsPossible), for: UIControl.Event.editingChanged)
        dueTextField.addTarget(self, action: #selector(checkIfSavingIsPossible), for: UIControl.Event.editingChanged)

        checkIfSavingIsPossible()
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
    
    @objc fileprivate func insertNewEntry() {
        let isValid = checkInputFields()
        if isValid {
            var newTodo = TodoData()
            newTodo.title = titleTextField.text
            newTodo.date = getDueDate()!
            newTodo.location = locationTextField.text
            newTodo.desc = descTextView.text
            todoListTableVC?.insertNewObject(todoData: newTodo)
            self.navigationController?.popToRootViewController(animated: true)
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
            let alert = UIAlertController(title: NSLocalizedString("Error while saving your to do", comment: ""), message: errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Got it", comment: ""), style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        return valid
    }
    
    @objc fileprivate func editExistingEntry() {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if let currentObject = managedObjectContext.object(with: (todoItem?.objectID)!) as? Todo {
            currentObject.title = titleTextField.text
            currentObject.date = getDueDate()
            currentObject.location = locationTextField.text
            currentObject.desc = descTextView.text
            currentObject.done = false
            
            do {
                try managedObjectContext.save()
                LocalNotification.dispatchlocalNotification(with: currentObject)
            } catch let error as NSError  {
                fatalError("Could not save \(error), \(error.userInfo)")
            }
            
            self.navigationController?.popViewController(animated: true)
            return
        }
    }

    deinit {
        todoListTableVC = nil
        todoItem = nil
        tbAccessoryView = nil
    }
}