//
//  Utilities.swift
//  myTodo
//
//  Created by Marc Hein on 15.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import UIKit

//MARK:- Check for Beta Testers
func isSimulatorOrTestFlight() -> Bool {
    return isSimulator() || isTestFlight()
}

func isSimulator() -> Bool {
    guard let path = Bundle.main.appStoreReceiptURL?.path else {
        return false
    }
    return path.contains("CoreSimulator")
}

func isTestFlight() -> Bool {
    guard let path = Bundle.main.appStoreReceiptURL?.path else {
        return false
    }
    return path.contains("sandboxReceipt")
}

// MARK: - showDialog
func showMessage(title: String, message: String, on view: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: NSLocalizedString("Got it", comment: ""), style: .cancel, handler: nil))
    DispatchQueue.main.async {
        view.present(alert, animated: true)
    }
}

// MARK:- Date functions
enum DateOptions {
    case date
    case time
    case both
}

func getDateOf(date: Date?, option: DateOptions) -> String? {
    guard let date = date else { return nil }
    let formatter = DateFormatter()
    if option == .date {
        formatter.dateFormat = "dd.MM.yyyy"
    } else if option == .time {
        formatter.dateFormat = "HH:mm"
    } else if option == .both {
        formatter.dateFormat = "dd.MM.yyyy - HH:mm"
    }
    return  formatter.string(from: date)
}

func getReleaseTitle() -> String {
    if isSimulator() {
        return "Simulator"
    } else if isTestFlight() {
        return "TestFlight"
    } else {
        return "App Store"
    }
}
