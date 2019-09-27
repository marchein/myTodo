//
//  TipJar+Transaction.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

extension TipJarTableViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
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
            hasData = true
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            print("There are no products.")
            if response.invalidProductIdentifiers.count != 0 {
                print(response.invalidProductIdentifiers.description)
            }
        }
        
        
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
                UserDefaults.standard.set(true, forKey: localStoreKeys.hasTipped)
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                impact.impactOccurred()
                showMessage(title: NSLocalizedString("tip_success", comment: ""), message: NSLocalizedString("tip_success_message", comment: ""), on: self)
            case SKPaymentTransactionState.failed:
                hud!.dismiss(animated: true)
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                showMessage(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("transaction_error", comment: ""), on: self)
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
}

