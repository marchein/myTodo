//
//  DetailViewController.swift
//  myTodo
//
//  Created by Marc Hein on 29.10.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit

class TodoDetailTableViewController: UITableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    
    var todoListTableVC: TodoListTableViewController?
    var todo: Todo? {
        didSet {
            title = todo?.title?.description
        }
    }
    var indexPath: IndexPath?
    let start = CFAbsoluteTimeGetCurrent()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("detail VC viewDidLoad")
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reconfigureView()
    }
    
    fileprivate func configureView() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.toolbar.isHidden = false
        
        if let todo = todo {
            titleLabel.text = todo.title?.description
            dueLabel.text = getDateOf(date: todo.date, option: .both)
            locationLabel.text = todo.location?.description
            descTextView.text = todo.desc?.description
            
            if todo.done {
                doneButton.image = #imageLiteral(resourceName: "todoDone")
            } else {
                doneButton.image = #imageLiteral(resourceName: "todoUndone")
            }
        }
        
        print("detail VC configureView done")
        let end = CFAbsoluteTimeGetCurrent() - start
        print("Took \(end) seconds")
    }
    
    fileprivate func reconfigureView() {
        navigationController?.toolbar.isHidden = false
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
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
            (action: UIAlertAction) in self.todoListTableVC?.tableView((self.todoListTableVC?.tableView!)!, commit: .delete, forRowAt: self.indexPath!)
            self.navigationController?.popToRootViewController(animated: true)
        })
        let shareAction = UIAlertAction(title: "Share", style: .default, handler: { (action: UIAlertAction) in
            self.showShareSheet()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(shareAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func showShareSheet() {
        if let currentTodo = todo {
            guard let dueDate = getDateOf(date: currentTodo.date, option: .both) else { return }
            let textToShare = "\(currentTodo.title!) is due \(dueDate), check out myTodo! Soon..."
            let myTodoImage = #imageLiteral(resourceName: "AppLogo")
            if let website = NSURL(string: "https://marc-hein-webdesign.de/") {
                let objectsToShare = [textToShare, website, myTodoImage] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
                activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
               
                self.present(activityVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if let currentObject = managedObjectContext.object(with: (todo?.objectID)!) as? Todo {
            currentObject.done = !currentObject.done

            if currentObject.done {
                LocalNotification.removeNotification(for: currentObject)
            } else {
                LocalNotification.dispatchlocalNotification(with: currentObject)
            }
            
            self.navigationController?.popToRootViewController(animated: true)
            
            do {
                try managedObjectContext.save()
                print("saved!")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            if currentObject.done {
                doneButton.image = #imageLiteral(resourceName: "todoDone")
            } else {
                doneButton.image = #imageLiteral(resourceName: "todoUndone")
            }
        }
    }
}
