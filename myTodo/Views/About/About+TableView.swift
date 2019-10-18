//
//  About+TableView.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 {
            return 0
        }
        return 	UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        DispatchQueue.main.async() {
            selectedCell.setSelected(false, animated: false)
        }
        
        switch (selectedCell) {
        case contactMailCell:
            sendSupportMail()
            break
        case rateCell:
            SKStoreReviewController.requestReview()
            break
        case appStoreCell:
            appStoreAction()
            break
        case developerCell:
            openSafariViewControllerWith(url: myTodo.website)
            break
        case resetNotificationCell:
            resetNotificationAction()
            break
        default:
            break
        }
        
        
    }
}
