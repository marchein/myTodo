//
//  AppIconTableViewController.swift
//  myTodo
//
//  Created by Marc Hein on 15.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit

class AppIconTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK:- Image functions
    internal func getAppIconFor(value: String?) -> UIImage? {
        if let imageName = value {
            return UIImage(named: imageName)
        } else {
            return Bundle.main.icon
        }
    }
    
    internal func changeIcon(to name: String?) {
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }
        UIApplication.shared.setAlternateIconName(name) { (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    internal func setSelectedImage(key: String?, cell: UITableViewCell?) {
        let currentAppIcon = UserDefaults.standard.string(forKey: localStoreKeys.currentAppIcon)
        if key ?? myTodo.defaultAppIcon == currentAppIcon {
            cell?.accessoryType = .checkmark
        }
    }
}
