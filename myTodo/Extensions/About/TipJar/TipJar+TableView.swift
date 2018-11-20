//
//  TipJar+TableView.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Table View
extension TipJarTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return productsArray.count > 0 ? productsArray.count : 1
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "introCell")
            cell.textLabel?.text = "\(NSLocalizedString("tip_greeting", comment: "")) 😌"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
            cell.detailTextLabel?.numberOfLines = 5
            cell.detailTextLabel?.lineBreakMode = .byWordWrapping
            cell.detailTextLabel?.text = NSLocalizedString("tip_desc", comment: "")
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = false
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tipCell", for: indexPath) as! TipTableViewCell
            if productsArray.count > indexPath.row {
                if let product = productsArray[indexPath.row] {
                    cell.tipTitle.text = product.localizedTitle
                    cell.tipDesc.text = product.localizedDescription
                    cell.purchaseButton.isHidden = false
                    cell.purchaseButton.setTitle(product.localizedPrice, for: .normal)
                }
            } else {
                cell.tipTitle.text = NSLocalizedString("no_tips", comment: "")
                cell.tipDesc.text = NSLocalizedString("no_tips_desc", comment: "")
                cell.purchaseButton.isHidden = true
                cell.tipDesc.isHidden = false
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 140.0
        } else {
            return hasData ? 68.0 : 100.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            selectedProductIndex = indexPath.row
            startTransaction()
        }
        
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }
}
