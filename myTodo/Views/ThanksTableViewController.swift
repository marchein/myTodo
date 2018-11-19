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
         "items": [Thank(name: "IQKeyboardManager", url: "https://github.com/hackiftekhar/IQKeyboardManager"),
                   Thank(name: "JGProgressHUD", url: "https://github.com/JonasGessner/JGProgressHUD"),
                   Thank(name: "MGSwipeTableCell", url: "https://github.com/MortimerGoro/MGSwipeTableCell")]],
        ["header": NSLocalizedString("Developers", comment: ""),
         "items": [Thank(name: "ChristianSelig")]],
        ["header": NSLocalizedString("Beta testers", comment: ""),
         "items": [Thank(name: "Auristrahl"),
                   Thank(name: "BugsB"),
                   Thank(name: "itsmelenni"),
                   Thank(name: "ZachariasFuchs")]
        ]
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
        if let _ = thank.url {
            cell.textLabel?.text = thank.name
        } else {
            cell.textLabel?.text = "@\(thank.name)"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let thanksValues = thanksItems[indexPath.section]["items"] as! [Thank]
        let thank = thanksValues[indexPath.row] as Thank
        if let thankUrl = thank.url {
            self.showLinksClicked(url: thankUrl)
        } else {
            self.openTwitter(username: thank.name)
        }
    }
}

struct Thank {
    let name: String
    let url: String?
    
    init(name: String, url: String? = nil) {
        self.name = name
        self.url = url
    }
}

// MARK:- Safari Extension
extension ThanksTableViewController: SFSafariViewControllerDelegate {
    fileprivate func openTwitter(username: String) {
        let tweetbotURL = URL(string: "tweetbot:///user_profile/\(username)")!
        let twitterURL = URL(string: "twitter:///user?screen_name=\(username)")!
        let webURL = "https://twitter.com/\(username)"
        let application = UIApplication.shared
        if application.canOpenURL(tweetbotURL as URL) {
            application.open(tweetbotURL as URL)
        } else if application.canOpenURL(twitterURL as URL) {
            application.open(twitterURL as URL)
        } else {
            showLinksClicked(url: webURL)
        }
    }
    
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
