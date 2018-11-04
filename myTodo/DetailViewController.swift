//
//  DetailViewController.swift
//  myTodo
//
//  Created by Marc Hein on 29.10.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    
    
    var detailItem: Todo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    fileprivate func configureView() {
        titleLabel.text = detailItem?.title?.description
        dueLabel.text = detailItem?.date?.description
        locationLabel.text = detailItem?.location?.description
        descTextView.text = detailItem?.desc?.description
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = detailItem?.title?.description
        
        if let toolbar = self.navigationController?.toolbar {
            toolbar.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSegue" {
            let editVC = segue.destination as! EditingTableViewController
            editVC.todoItem = detailItem
        }
    }

    @IBAction func shareAction(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive)
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
        let textToShare = "Swift is awesome!  Check out this website about it!"
        
        if let myWebsite = NSURL(string: "http://www.codingexplorer.com/") {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            //
            
            self.present(activityVC, animated: true, completion: nil)
        }
    }
}
