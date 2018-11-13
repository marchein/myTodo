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
    @IBOutlet weak var showDialogCell: UITableViewCell!
    @IBOutlet weak var appIconCell: UITableViewCell!
    @IBOutlet weak var appIconIV: UIImageView!
    @IBOutlet weak var appVersionCell: UITableViewCell!
    @IBOutlet weak var contactMailCell: UITableViewCell!
    @IBOutlet weak var developerTwitterCell: UITableViewCell!
    @IBOutlet weak var appStoreCell: UITableViewCell!
    @IBOutlet weak var developerCell: UITableViewCell!
    @IBOutlet weak var resetNotificationCell: UITableViewCell!
    //@IBOutlet weak var generateDemoDataCell: UITableViewCell!
    @IBOutlet weak var confirmDialogSwitch: UISwitch!
    
    // MARK:- Class Attributes
    private let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    private let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    private var hasTipped = false
    private var currentAppIcon: String?
    
    // MARK: System Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        appVersionCell.detailTextLabel?.text = appVersionString
        confirmDialogSwitch.isOn = UserDefaults.standard.bool(forKey: "showConfirmDialog")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reconfigureView()
    }
    
    fileprivate func reconfigureView() {
        currentAppIcon = UserDefaults.standard.string(forKey: "currentIcon")
        if let appIcon = currentAppIcon {
            appIconIV.image = appIcon == "default" ? Bundle.main.icon : UIImage(named: appIcon)
        }
        hasTipped = UserDefaults.standard.bool(forKey: "hasTipped")
        tableView.reloadData()
    }
    
    // MARK:- Table View
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "\(NSLocalizedString("Build number", comment: "")): \(buildNumber)"
        }
        
        if section == 2 {
            return NSLocalizedString("caution_desc", comment: "")
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return  44.0 }
        if (selectedCell == appIconCell && !hasTipped) {
            return 0.0
        } else if selectedCell == developerCell {
            return 64.0
        } else {
            return 44.0
        }
    }
    
    /*fileprivate func generateDemoData() {
        print("Demo")
        guard let mainVC = (tabBarController?.viewControllers![0] as? UINavigationController)?.topViewController as? TodoListTableViewController else { return }
        let data = [
            TodoData(title: "Band engagieren", date: Date().addedBy(minutes: (60 * 24 * 3)), location: "Zuhause", desc: nil),
            TodoData(title: "Bühnentechnik besorgen", date: Date().addedBy(minutes: (60 * 24 * 3)), location: "Zuhause", desc: nil),
            TodoData(title: "Catering bestellen", date: Date().addedBy(minutes: (60 * 24 * 3)), location: "Zuhause", desc: nil),
            TodoData(title: "Präsentation erstellen", date: Date().addedBy(minutes:  (60 * 24 * 7 + 74)), location: "Gemeindehaus", desc: "Es muss eine Präsentation über das Unternehmen und unsere Produkte erstellt werden."),
            TodoData(title: "Halle ausräumen", date: Date().addedBy(minutes:  (60 * 24 * 10 + 80)), location: "Gemeindehaus", desc: nil),
            TodoData(title: "Deko aufhängen", date: Date().addedBy(minutes: (60 * 24 * 10 + 160)), location: "Gemeindehaus", desc: nil),
            TodoData(title: "Tische & Stühle aufstellen", date: Date().addedBy(minutes: (60 * 24 * 10 + 240)), location: "Gemeindehaus", desc: nil),
        ]
        for item in data {
            mainVC.insertNewObject(todoData: item)
        }
    }*/
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        if selectedCell == contactMailCell {
            sendEmail()
        } else if selectedCell == developerTwitterCell {
            let username =  "myTodo_app"
            openTwitter(username: username)
        } else if selectedCell == appStoreCell {
            let appID = "1441790770"
            let urlStr = "itms-apps://itunes.apple.com/app/id\(appID)"
            if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        } else if selectedCell == developerCell {
            showLinksClicked(url: "https://marc-hein-webdesign.de")
        } else if selectedCell == resetNotificationCell {
            LocalNotification.center.removeAllDeliveredNotifications()
            LocalNotification.center.removeAllPendingNotificationRequests()
            resetNotificationCell.setSelected(false, animated: true)
        } /*else if selectedCell == generateDemoDataCell {
            generateDemoData()
        }*/
        selectedCell.setSelected(false, animated: false)
    }
    @IBAction func confirmDialogSwitchAction(_ sender: Any) {
        UserDefaults.standard.set(confirmDialogSwitch.isOn, forKey: "showConfirmDialog")
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
            mail.setMessageBody(NSLocalizedString("support_mail_body", comment: ""), isHTML: false)
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
