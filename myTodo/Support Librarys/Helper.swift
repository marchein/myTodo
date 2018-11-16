//
//  Helper.swift
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

// MARK:- showDialog
func showMessage(title: String, message: String, done: String, view: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: done, style: .cancel, handler: nil))
    view.present(alert, animated: true)
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

extension Date {
    func addedBy(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}

func maskImage(image: UIImage, mask: UIImage) -> UIImage {
    guard let imageReference = image.cgImage else { fatalError() }
    guard let maskReference = mask.cgImage else { fatalError() }
    
    let imageMask = CGImage(maskWidth: maskReference.width,
                            height: maskReference.height,
                            bitsPerComponent: maskReference.bitsPerComponent,
                            bitsPerPixel: maskReference.bitsPerPixel,
                            bytesPerRow: maskReference.bytesPerRow,
                            provider: maskReference.dataProvider!, decode: nil, shouldInterpolate: true)
    
    let maskedReference = imageReference.masking(imageMask!)
    let maskedImage = UIImage(cgImage: maskedReference!)
    
    return maskedImage
}

extension Bundle {
    public var icon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any], let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any], let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String], let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
}
