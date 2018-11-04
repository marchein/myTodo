//
//  EditingTableViewController.swift
//  myTodo
//
//  Created by Marc Hein on 03.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit

class EditingTableViewController: UITableViewController {
    
    var isSetup = false
    var masterVC: MasterViewController? = nil
    var todoItem: Todo?

    // MARK:- Outlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dueTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func configureView() {
        if let todo = todoItem {
            title = "Edit"
            titleTextField.text = todo.title?.description
            dueTextField.text = todo.date?.description
            locationTextField.text = todo.location?.description
            descTextField.text = todo.desc?.description
        } else {
            title = "Add"
        }
        
        if let toolbar = self.navigationController?.toolbar {
            toolbar.isHidden = true
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            var newTodo = TodoData()
            newTodo.title = titleTextField.text
            newTodo.location = locationTextField.text
            newTodo.desc = descTextField.text
            print("todo to add: \(newTodo)")
            masterVC?.insertNewObject(todoData: newTodo)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
