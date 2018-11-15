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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        let maskImage = UIImage(named: "app_mask")!
        let maskView = UIImageView(image: maskImage)
        cell.appIcon.mask = maskView
        maskView.frame = cell.appIcon.bounds
        cell.setTitle(title: imageOfCurrentCell?.iconTitle)
        return cell
    }

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
