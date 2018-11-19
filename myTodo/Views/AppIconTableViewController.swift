//
//  AppIconTableViewController.swift
//  myTodo
//
//  Created by Marc Hein on 15.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit

class AppIconTableViewController: UITableViewController {
    var appIcons: AppIcons?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK:- Image functions
    
    fileprivate func getImageFor(value: String?) -> UIImage? {
        if let imageName = value {
            return UIImage(named: imageName)
        } else {
            return Bundle.main.icon
        }
    }
    
    func changeIcon(to name: String?) {
        guard UIApplication.shared.supportsAlternateIcons else {
            return;
        }
        UIApplication.shared.setAlternateIconName(name) { (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func setSelectedImage(key: String?, cell: UITableViewCell?) {
        let currentAppIcon = UserDefaults.standard.string(forKey: "currentIcon")
        if key ?? "default" == currentAppIcon {
            cell?.accessoryType = .checkmark
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let appIcons = appIcons else {
            fatalError()
        }
        return appIcons.count()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let appIcons = appIcons else {
            fatalError()
        }
        let selectedIcon = appIcons.getIcon(for: indexPath.row)?.iconName
        DispatchQueue.main.async(execute: { () -> Void in
            UserDefaults.standard.set(selectedIcon ?? "default", forKey: "currentIcon")
            self.setSelectedImage(key: selectedIcon, cell: tableView.cellForRow(at: indexPath))
            self.tableView.reloadData()
        })
        changeIcon(to: selectedIcon)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let appIcons = appIcons else {
            fatalError()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "appIcons", for: indexPath) as! AppIconTableViewCell
        let imageOfCurrentCell = appIcons.getIcon(for: indexPath.row)
        cell.accessoryType = .none
        setSelectedImage(key: imageOfCurrentCell?.iconName, cell: cell)
        cell.appIcon.image = getImageFor(value: imageOfCurrentCell?.iconName)
        cell.setTitle(title: imageOfCurrentCell?.iconTitle)
        return cell
    }
}
