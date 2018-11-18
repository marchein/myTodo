//
//  TipJarTableViewController.swift
//  myTodo
//
//  Created by Marc Hein on 13.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit
import StoreKit
import SafariServices

import JGProgressHUD

class TipJarTableViewController: UITableViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    

    let smallTip = "de.marc_hein.myTodo.tip.small"
    let mediumTip = "de.marc_hein.myTodo.tip.medium"
    let largeTip = "de.marc_hein.myTodo.tip.large"

    var productIDs: Array<String> = []
    var productsArray: Array<SKProduct?> = []
    var selectedProductIndex: Int!
    var transactionInProgress = false
    var hud: JGProgressHUD? = JGProgressHUD(style: .dark)
    var hasData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)

        setupProducts()
        requestProductInfo()
        hud!.textLabel.text = NSLocalizedString("loading", comment: "")
    }

    // MARK:- IAP
    fileprivate func setupProducts() {
        productIDs.append(smallTip)
        productIDs.append(mediumTip)
        productIDs.append(largeTip)
    }
    
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = NSSet(array: productIDs)
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            productRequest.delegate = self
            productRequest.start()
        } else {
            print("Cannot perform In App Purchases.")
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                productsArray.append(product)
            }
            productsArray = productsArray.reversed()
        } else {
            print("There are no products.")
        }
        hasData = true
        tableView.reloadData()
        if response.invalidProductIdentifiers.count != 0 {
            print(response.invalidProductIdentifiers.description)
        }
    }
    
    @IBAction func tipButtonAction(_ sender: UIButton) {
        guard let cell = sender.superview?.superview?.superview as? TipTableViewCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
    }
    
    func startTransaction() {
        if transactionInProgress || productsArray.count < 1 {
            return
        }

        let payment = SKPayment(product: self.productsArray[self.selectedProductIndex]!)
        SKPaymentQueue.default().add(payment)
        self.transactionInProgress = true
        hud!.show(in: navigationController!.view)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                hud!.dismiss(animated: true)
                UserDefaults.standard.set(true, forKey: "hasTipped")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                showMessage(title: NSLocalizedString("tip_success", comment: ""), message: NSLocalizedString("tip_success_message", comment: ""))
            case SKPaymentTransactionState.failed:
                hud!.dismiss(animated: true)
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                showMessage(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("transaction_error", comment: ""))
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    
    
    func showMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Got it", comment: ""), style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Table view data source

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

class TipTableViewCell: UITableViewCell {
    @IBOutlet weak var tipTitle: UILabel!
    @IBOutlet weak var tipDesc: UILabel!
    @IBOutlet weak var purchaseButton: BorderedButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}