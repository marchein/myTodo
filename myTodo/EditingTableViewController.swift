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
    var todoListTableVC: TodoListTableViewController? = nil
    var todoItem: Todo?
    var indexPath: IndexPath?
    var datePickerView: UIDatePicker?
    var tbAccessoryView : UIToolbar?
    var maxTag = 0
    var textSubViews: [UIView]?

    // MARK:- Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dueTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.toolbar.isHidden = true
    }

    fileprivate func configureView() {
        navigationController?.toolbar.isHidden = true
        
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
            descTextView.text = todo.desc?.description
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(self.editExistingEntry))
        } else {
            title = "Add"
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"
            dueTextField.text = dateFormatter.string(from: now)
            datePickerView?.date = now
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(self.insertNewEntry))
        }
        
        textSubViews = [titleTextField, dueTextField, locationTextField, descTextView]
        findMaxTFTag()
    }
    
    @objc fileprivate func handleDatePicker(sender: UIDatePicker) {
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
    
    @objc fileprivate func insertNewEntry() {
        let isValid = checkInputFields()
        if isValid {
            var newTodo = TodoData()
            newTodo.title = titleTextField.text
            newTodo.date = getDueDate()!
            newTodo.location = locationTextField.text
            newTodo.desc = descTextView.text
            print("todo to add: \(newTodo)")
            todoListTableVC?.insertNewObject(todoData: newTodo)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func getDueDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm"
        guard let date = dateFormatter.date(from: dueTextField.text!) else {
            print("ERROR: Date conversion failed due to mismatched format.")
            return nil
        }
        return date
    }
    
    func checkInputFields() -> Bool {
        var valid = true
        var errorMessage: String = "No error"
        
        if titleTextField.text!.count < 1 {
            valid = false
            errorMessage = "Title field cannot be empty"
        }
        
        if getDueDate() == nil {
            valid = false
            errorMessage = "Something seems wrong with your due date field, try again please."
        }
        
        if !valid {
            let alert = UIAlertController(title: "Error while saving your to do", message: errorMessage, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Verstanden", style: .cancel, handler: nil))
            
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
                print("saved!")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            self.navigationController?.popToRootViewController(animated: true)
            
            return
        }
    }
    
    var curTag = 0
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        curTag = textField.tag
        textField.inputAccessoryView = getToolbarAccessoryView()
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        curTag = textView.tag
        textView.inputAccessoryView = getToolbarAccessoryView()
        return true
    }
    
    func getToolbarAccessoryView() -> UIView? {
        if tbAccessoryView == nil {
            tbAccessoryView = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
            let bbiPrev = UIBarButtonItem.init(title: "Previous", style: .plain, target: self, action: #selector(doBtnPrev))
            let bbiNext = UIBarButtonItem.init(title: "Next", style: .plain, target: self, action: #selector(doBtnNext))
            let bbiSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let bbiSubmit = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doBtnSubmit))
            tbAccessoryView?.items = [bbiPrev, bbiNext, bbiSpacer, bbiSubmit]
        }
        return tbAccessoryView
    }
    
    @objc
    func doBtnPrev() {
        // decrement or roll over
        curTag = curTag == 0 ? maxTag : curTag - 1
        findTFWithTag(tag: curTag)?.becomeFirstResponder()
    }
    
    @objc
    func doBtnNext() {
        // increment or roll over
        curTag = curTag == maxTag ? 0 : curTag + 1
        findTFWithTag(tag: curTag)?.becomeFirstResponder()
    }
    
    @objc
    func doBtnSubmit() {
        findTFWithTag(tag: curTag)!.resignFirstResponder()
    }
    
    func findMaxTFTag() {
        textSubViews!.forEach { (v) in
            if v is UITextField && v.tag > maxTag || v is UITextView && v.tag > maxTag {
                maxTag = v.tag
            }
        }
    }
    
    func findTFWithTag(tag : Int) -> UIView? {
        var returnValue : UIView?
        textSubViews!.forEach { (v) in
            if v.tag == tag {
                if let result = v as? UITextField {
                    returnValue = result
                }

                if let result = v as? UITextView {
                    returnValue = result
                }
            }
        }
        return returnValue
    }
    
    deinit {
        todoListTableVC = nil
        todoItem = nil
        tbAccessoryView = nil
    }
}

extension Date {
    func addedBy(minutes:Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}
