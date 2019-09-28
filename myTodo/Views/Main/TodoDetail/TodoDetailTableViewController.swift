//
//  DetailViewController.swift
//  myTodo
//
//  Created by Marc Hein on 29.10.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit

class TodoDetailTableViewController: UITableViewController, UIPopoverControllerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var descCell: UITableViewCell!
    
    var todoListTableVC: TodoListTableViewController?
    var todo: Todo?
    var indexPath: IndexPath?
    var firstCallDone = false
    let notification = UINotificationFeedbackGenerator()
    var isPeeking = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstCallDone {
            configureView()
        }
        firstCallDone = true
        
        tableView.reloadData()
        
        if !isPeeking {
            navigationController?.setToolbarHidden(false, animated: false)
        }
        
        if todo == nil, let splitVC = splitViewController {
            let splitNavVC = splitVC.viewControllers[1] as! UINavigationController
            splitNavVC.performSegue(withIdentifier: myTodoSegue.emptyDetailView, sender: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isPeeking = false
    }
    
    fileprivate func configureView() {
        navigationController?.toolbar.isHidden = false
        navigationItem.largeTitleDisplayMode = .never
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        
        if let todo = todo {
            guard let title = todo.title else { return }
            guard let location = todo.location else { return }
            guard let description = todo.desc else { return }
            titleLabel.text = title
            dueLabel.text = getDateOf(date: todo.date, option: .both)
            
            if location.count > 0 {
                locationLabel.text = location
                
                if #available(iOS 13.0, *) {
                    locationLabel.textColor = UIColor.label
                } else {
                    locationLabel.textColor = UIColor.black
                }
            } else {
                locationLabel.text = NSLocalizedString("Unknown location", comment: "")
                locationLabel.textColor = UIColor.lightGray
            }
            
            if description.count > 0 {
                descTextView.text = description
                if #available(iOS 13.0, *) {
                   descTextView.textColor = UIColor.label
               } else {
                   descTextView.textColor = UIColor.black
               }
            } else {
                descTextView.text = NSLocalizedString("No description available", comment: "")
                descTextView.textColor = UIColor.lightGray
            }
            
            setDoneButton(todo)
        } else {
            editButton.isEnabled = false
            doneButton.isEnabled = false
            shareButton.isEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == myTodoSegue.edit {
            let editVC = segue.destination as! TodoEditingTableViewController
            editVC.todoItem = todo
            editVC.indexPath = indexPath
            editVC.todoListTableVC = todoListTableVC
        }
    }
    
    @IBAction func shareAction(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: {
            (action: UIAlertAction) in self.todoListTableVC?.tableView((self.todoListTableVC?.tableView!)!, commit: .delete, forRowAt: self.indexPath!)
            self.notification.notificationOccurred(.warning)
            self.navigationController?.popToRootViewController(animated: true)
        })
        
        
        let shareAction = UIAlertAction(title: NSLocalizedString("Share", comment: ""), style: .default, handler: { (action: UIAlertAction) in
            if let shareSheet = getShareSheet(for: self.todo) {
                // FIXME: repair Sharesheet on iPad
                if let popoverController = shareSheet.popoverPresentationController {
                    self.setPopOverController(popOver: popoverController)
                }
                self.present(shareSheet, animated: true, completion: nil)
            }
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        
        optionMenu.addAction(shareAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)

        if let popoverController = optionMenu.popoverPresentationController {
            setPopOverController(popOver: popoverController)
        }
        
        self.present(optionMenu, animated: true, completion: nil)
    }
        
    @IBAction func doneButtonTapped(_ sender: Any) {
        notification.notificationOccurred(.success)
        if let splitVC = splitViewController {
            if (splitVC.viewControllers.count > 1) {
                print("Split VC childs: \(splitVC.viewControllers)")
                let navController = splitVC.viewControllers[1] as? UINavigationController
                navController?.performSegue(withIdentifier: myTodoSegue.emptyDetailView, sender: self)
            } else {
                let navController = splitVC.viewControllers[0] as? UINavigationController
                navController?.popViewController(animated: true)
            }
        }
        todoListTableVC?.doneAction(selectedItem: todo)
    
        DispatchQueue.main.async() {
            if let todo = self.todo {
                self.setDoneButton(todo)
            }
        }
    }
    
    fileprivate func setPopOverController(popOver: UIPopoverPresentationController) {
        popOver.sourceView = self.view
        popOver.permittedArrowDirections = [.down]
        popOver.barButtonItem = shareButton
    }
    
    func setDoneButton(_ todo: Todo) {
        doneButton.image = todo.done ? #imageLiteral(resourceName: "todoDone") : #imageLiteral(resourceName: "todoUndone")
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
