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
    @IBOutlet weak var confirmDialogSwitch: UISwitch!
    
    // MARK:- Class Attributes
    private let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    private let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    private var hasTipped = false
    private var currentAppIcon: String?
    
//    private let appIcons = [
//        ["icon": nil, "title": "Default"],
//        ["icon": "myTodo1", "title": "myTodo (2013)"],
//        ["icon": "myTodo2", "title": "myTodo (2014)"],
//        ["icon": "myTodo_christmas", "title": "Christmas 1"]
//    ]
    
    private let appIcons = AppIcons(icons: [
        AppIcon(iconName: nil, iconTitle: "Default"),
        AppIcon(iconName: "myTodo1", iconTitle: "myTodo (2013)"),
        AppIcon(iconName: "myTodo2", iconTitle: "myTodo (2014)"),
        AppIcon(iconName: "brains", iconTitle: "Braaaaaains"),
        AppIcon(iconName: "wet", iconTitle: "Waterdrawing"),
        AppIcon(iconName: "pinsel", iconTitle: "Sprayed"),
        AppIcon(iconName: "myTodo_christmas", iconTitle: "Christmas")
    ])
    
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
        if !appIcons.contains(iconName: currentAppIcon) {
            currentAppIcon = "default"
            UserDefaults.standard.set(currentAppIcon, forKey: "currentIcon")
        }
        
        if let appIcon = currentAppIcon {
            let maskImage = UIImage(named: "app_mask")!
            print(maskImage)
            let maskView = UIImageView(image: maskImage)
            appIconIV.image = appIcon == "default" ? Bundle.main.icon : UIImage(named: appIcon)
            appIconIV.mask = maskView
            maskView.frame = appIconIV.bounds
        }
        hasTipped = UserDefaults.standard.bool(forKey: "hasTipped")
        tableView.reloadData()
    }
    
    // MARK:- Table View
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            var releaseString: String?
            if isSimulator() {
                releaseString = "Simulator"
            } else if isTestFlight() {
                releaseString = "TestFlight"
            } else {
                releaseString = "App Store"
            }
            return "\(NSLocalizedString("Build number", comment: "")): \(buildNumber) (\(releaseString!))"
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
        } else if selectedCell == resetNotificationCell {
            LocalNotification.center.removeAllDeliveredNotifications()
            LocalNotification.center.removeAllPendingNotificationRequests()
            resetNotificationCell.setSelected(false, animated: true)
        }
        selectedCell.setSelected(false, animated: false)
    }
    
    @IBAction func confirmDialogSwitchAction(_ sender: Any) {
        UserDefaults.standard.set(confirmDialogSwitch.isOn, forKey: "showConfirmDialog")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "appIconSegue" {
            guard let appIconVC = segue.destination as? AppIconTableViewController else { return }
            appIconVC.appIcons = appIcons
        }
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
