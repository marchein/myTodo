//
//  AboutViewController.swift
//  myTodo
//
//  Created by Marc Hein on 09.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit
import CoreData
import MessageUI
import SafariServices

class AboutTableViewController: UITableViewController {

    // MARK:- Outlets
    @IBOutlet weak var appVersionCell: UITableViewCell!
    @IBOutlet weak var contactMailCell: UITableViewCell!
    @IBOutlet weak var webSupportCell: UITableViewCell!
    @IBOutlet weak var developerCell: UITableViewCell!
    @IBOutlet weak var resetNotificationCell: UITableViewCell!
    
    // MARK:- Class Attributes
    private let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    private let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    
    // MARK: System Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        appVersionCell.detailTextLabel?.text = appVersionString
    }
    
    // MARK:- Table View
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Build number: \(buildNumber)"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        if selectedCell == contactMailCell {
            sendEmail()
        } else if selectedCell == webSupportCell {
            showLinksClicked(url: "https://mytodoapp.de")
        } else if selectedCell == developerCell {
            showLinksClicked(url: "https://marc-hein-webdesign.de")
        } else if selectedCell == resetNotificationCell {
            LocalNotification.center.removeAllDeliveredNotifications()
            LocalNotification.center.removeAllPendingNotificationRequests()
            resetNotificationCell.setSelected(false, animated: true)
        }
        selectedCell.setSelected(false, animated: true)
    }
}

// MARK:- Mail Extension
extension AboutTableViewController: MFMailComposeViewControllerDelegate {
    fileprivate func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            
            mail.mailComposeDelegate = self
            mail.setSubject("[myTodo] - Version \(appVersionString) (Build: \(buildNumber))")
            mail.setToRecipients(["info@mytodoapp.de"])
            mail.setMessageBody("Why are you contacting the support of myTodo?<br />\n", isHTML: true)
            
            present(mail, animated: true)
        } else {
            print("No mail account configured")
            showLinksClicked(url: "https://mytodoapp.de/kontakt/")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

// MARK:- Safari Extension
extension AboutTableViewController: SFSafariViewControllerDelegate {
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
