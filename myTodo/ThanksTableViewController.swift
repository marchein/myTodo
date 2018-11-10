//
//  ThanksTableViewController.swift
//  myTodo
//
//  Created by Marc Hein on 10.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit
import SafariServices

class ThanksTableViewController: UITableViewController {

     // MARK:- Class Attributes
    private let thanksItems = [
        ["header": "Frameworks",
         "items": [Thank(name: "MGSwipeTableCell", url: "https://github.com/MortimerGoro/MGSwipeTableCell")]],
        ["header": "Persons",
         "items": [Thank(name: "Christian Selig", url: "https://twitter.com/ChristianSelig"),
                   Thank(name: "Rodrigo Bueno Tomiosso", url: "https://github.com/mourodrigo")]]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return thanksItems.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionValues = thanksItems[section]["items"] as? [Thank]
        return sectionValues?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return thanksItems[section]["header"] as? String
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "thanksCell", for: indexPath)
        let thanksValues = thanksItems[indexPath.section]["items"] as! [Thank]
        let thank = thanksValues[indexPath.row] as Thank
        cell.textLabel?.text = thank.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let thanksValues = thanksItems[indexPath.section]["items"] as! [Thank]
        let thank = thanksValues[indexPath.row] as Thank
        self.showLinksClicked(url: thank.url)
    }
}

struct Thank {
    let name: String
    let url: String
}

// MARK:- Safari Extension

extension ThanksTableViewController: SFSafariViewControllerDelegate {
    fileprivate func showLinksClicked(url: String) {
        guard let safariURL = URL(string: url) else { return }
        
        let safariVC = SFSafariViewController(url: safariURL)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
    
    fileprivate func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
