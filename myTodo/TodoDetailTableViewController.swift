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
    
    
    var todoListTableVC: TodoListTableViewController?
    var todo: Todo? {
        didSet {
            title = todo?.title?.description
        }
    }
    var indexPath: IndexPath?
    var firstCallDone = false

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
    }
    
    fileprivate func configureView() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.toolbar.isHidden = false
        
        if let todo = todo {
            guard let title = todo.title else { return }
            guard let location = todo.location else { return }
            guard let description = todo.desc else { return }
            titleLabel.text = title
            dueLabel.text = getDateOf(date: todo.date, option: .both)
            
            if location.count > 0 {
                locationLabel.text = location
                locationLabel.textColor = UIColor.black
            } else {
                locationLabel.text = NSLocalizedString("Unknown location", comment: "")
                locationLabel.textColor = UIColor.lightGray
            }
            
            if description.count > 0 {
                descTextView.text = description
                descTextView.textColor = UIColor.black
            } else {
                descTextView.text = NSLocalizedString("No description available", comment: "")
                descTextView.textColor = UIColor.lightGray
            }
            
            setDoneButton()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSegue" {
            let editVC = segue.destination as! EditingTableViewController
            editVC.todoItem = todo
            editVC.indexPath = indexPath
            editVC.todoListTableVC = todoListTableVC
        }
    }

    @IBAction func shareAction(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: {
            (action: UIAlertAction) in self.todoListTableVC?.tableView((self.todoListTableVC?.tableView!)!, commit: .delete, forRowAt: self.indexPath!)
            self.navigationController?.popToRootViewController(animated: true)
        })
        let shareAction = UIAlertAction(title: NSLocalizedString("Share", comment: ""), style: .default, handler: { (action: UIAlertAction) in
            self.showShareSheet()
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        
        optionMenu.addAction(shareAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.permittedArrowDirections = [.down]
            popoverController.barButtonItem = shareButton
        }
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func showShareSheet() {
        if let currentTodo = todo {
            guard let dueDate = getDateOf(date: todo?.date, option: .date) else { return }
            guard let dueTime = getDateOf(date: todo?.date, option: .time) else { return }
            
            let textToShare = "\(currentTodo.title!) \(NSLocalizedString("is_due_sharing", comment: "")) \(dueDate) \(NSLocalizedString("at", comment: "")) \(dueTime) \(NSLocalizedString("time unit", comment: "at... __UHR__")).\n\n\(NSLocalizedString("mytodo_promo_sharing", comment: ""))"
            if let website = NSURL(string: "https://mytodoapp.de/") {
                let objectsToShare = [textToShare, website] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activityVC.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
                
                if let popoverController = activityVC.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.permittedArrowDirections = [.down]
                    popoverController.barButtonItem = shareButton
                }
                
                self.present(activityVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        todoListTableVC?.doneAction(selectedItem: todo)
    
        DispatchQueue.main.async() {
            self.setDoneButton()
        }
    }
    
    fileprivate func setDoneButton() {
        doneButton.image = (todo?.done ?? false) ? #imageLiteral(resourceName: "todoDone") : #imageLiteral(resourceName: "todoUndone")
    }
}
