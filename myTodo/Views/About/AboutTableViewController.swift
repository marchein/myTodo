//
//  AboutViewController.swift
//  myTodo
//
//  Created by Marc Hein on 09.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

class AboutTableViewController: UITableViewController {

    // MARK:- Outlets
    @IBOutlet weak var showDialogCell: UITableViewCell!
    @IBOutlet weak var appIconCell: UITableViewCell!
    @IBOutlet weak var appIconIV: UIImageView!
    @IBOutlet weak var appVersionCell: UITableViewCell!
    @IBOutlet weak var contactMailCell: UITableViewCell!
    @IBOutlet weak var developerTwitterCell: UITableViewCell!
    @IBOutlet weak var appStoreCell: UITableViewCell!
    @IBOutlet weak var developerCell: UITableViewCell!
    @IBOutlet weak var resetNotificationCell: UITableViewCell!
    @IBOutlet weak var confirmDialogSwitch: UISwitch!
    
    
    // MARK:- Class Attributes
    public var todoListTableVC: TodoListTableViewController?
    private var hasTipped = false
    private var currentAppIcon: String?
    
    // MARK: System Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        appVersionCell.detailTextLabel?.text = myTodo.versionString
        confirmDialogSwitch.isOn = UserDefaults.standard.bool(forKey: localStoreKeys.showConfirmDialog)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbar.isHidden = true
        navigationController?.navigationBar.prefersLargeTitles = true
        reconfigureView()
    }
    
    fileprivate func reconfigureView() {
        currentAppIcon = UserDefaults.standard.string(forKey: localStoreKeys.currentAppIcon)
        if !myTodo.appIcons.contains(iconName: currentAppIcon) {
            currentAppIcon = myTodo.defaultAppIcon
            UserDefaults.standard.set(currentAppIcon, forKey: localStoreKeys.currentAppIcon)
        }
        
        if let appIcon = currentAppIcon {
            appIconIV.image = appIcon == myTodo.defaultAppIcon ? Bundle.main.icon : UIImage(named: appIcon)
            appIconIV.roundCorners(radius: 6)
        }
        tableView.reloadData()
    }
    
    @IBAction func confirmDialogSwitchAction(_ sender: Any) {
        UserDefaults.standard.set(confirmDialogSwitch.isOn, forKey: localStoreKeys.showConfirmDialog)
    }
    
    @IBAction func closeModal(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
