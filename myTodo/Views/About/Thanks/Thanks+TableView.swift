//
//  Thanks+TableView.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import UIKit

// MARK: - TableView
extension ThanksTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return myTodo.thanksItems.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionValues = myTodo.thanksItems[section]["items"] as? [Thank]
        return sectionValues?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return myTodo.thanksItems[section]["header"] as? String
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "thanksCell", for: indexPath)
        let thanksValues = myTodo.thanksItems[indexPath.section]["items"] as! [Thank]
        let thank = thanksValues[indexPath.row] as Thank
        if let _ = thank.url {
            cell.textLabel?.text = thank.name
        } else {
            cell.textLabel?.text = "@\(thank.name)"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let thanksValues = myTodo.thanksItems[indexPath.section]["items"] as! [Thank]
        let thank = thanksValues[indexPath.row] as Thank
        if let thankUrl = thank.url {
            self.showLinksClicked(url: thankUrl)
        } else {
            self.openTwitter(username: thank.name)
        }
    }
}
