//
//  About+TableView.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Table View Extension
extension AboutTableViewController {
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "\(NSLocalizedString("Build number", comment: "")): \(myTodo.buildNumber) (\(getReleaseTitle()))"
        }
        
        if section == 2 {
            return NSLocalizedString("caution_desc", comment: "")
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        if selectedCell == contactMailCell {
            sendSupportMail()
        } else if selectedCell == developerTwitterCell {
            openTwitter(username: myTodo.twitterName)
        } else if selectedCell == appStoreCell {
            let urlStr = "itms-apps://itunes.apple.com/app/id\(myTodo.appStoreId)"
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
}
