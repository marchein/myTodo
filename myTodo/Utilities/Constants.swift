//
//  Constants.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import UIKit

struct localStoreKeys {
    // is app setup?
    static let appSetup = "appSetup"
    // should show confirm dialog when todo has been done?
    static let showConfirmDialog = "showConfirmDialog"
    // which is the current App icon?
    static let currentAppIcon = "currentIcon"
    // is beta tester?
    static let isTester = "isTester"
    // has tipped?
    static let hasTipped = "hasTipped"
}

struct myTodoIAP {
    static let smallTip = "de.marc_hein.myTodo.tip.small"
    static let mediumTip = "de.marc_hein.myTodo.tip.medium"
    static let largeTip = "de.marc_hein.myTodo.tip.large"
    
    static let allTips = [myTodoIAP.smallTip, myTodoIAP.mediumTip, myTodoIAP.largeTip]
}

struct myTodoSegue {
    static let showDetail = "showDetail"
    static let addTodo = "addSegue"
    static let edit = "editSegue"
    static let quickEdit = "quickEditSegue"
    static let emptyDetailView = "emptyDetail"
}

struct myTodo {
    static let appStoreId = "1441790770"
    static let twitterName = "myTodo_app"
    static let mailAdress = "info@mytodoapp.de"
    static let website = "https://mytodoapp.de/"
    static let supportPage = "https://mytodoapp.de/kontakt/"
    static let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    static let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    static let defaultAppIcon = "default"
    static var appIcons = AppIcons(icons: [
        AppIcon(iconName: nil, iconTitle: "myTodo (2018)"),
        AppIcon(iconName: "myTodo2", iconTitle: "myTodo (2014)"),
        AppIcon(iconName: "myTodo1", iconTitle: "myTodo (2013)"),
        AppIcon(iconName: "brains", iconTitle: "Braaaaaains", startDate: Date().dateBy(date: "01.12.2018")),
        AppIcon(iconName: "wet", iconTitle: "Waterdrawing", startDate: Date().dateBy(date: "01.12.2018")),
        AppIcon(iconName: "pinsel", iconTitle: "Sprayed", startDate: Date().dateBy(date: "01.12.2018")),
        AppIcon(iconName: "myTodo_christmas", iconTitle: NSLocalizedString("christmas_2018", comment: ""), startDate: Date().dateBy(date: "01.12.2018"), endDate: Date().dateBy(date: "06.01.2019"))
    ])
    static let thanksItems = [
        ["header": "Frameworks",
         "items": [Thank(name: "IQKeyboardManager", url: "https://github.com/hackiftekhar/IQKeyboardManager"),
                   Thank(name: "JGProgressHUD", url: "https://github.com/JonasGessner/JGProgressHUD"),
                   Thank(name: "MGSwipeTableCell", url: "https://github.com/MortimerGoro/MGSwipeTableCell")]],
        ["header": NSLocalizedString("Developers", comment: ""),
         "items": [Thank(name: "ChristianSelig")]],
        ["header": NSLocalizedString("Beta testers", comment: ""),
         "items": [Thank(name: "Auristrahl"),
                   Thank(name: "BugsB"),
                   Thank(name: "itsmelenni"),
                   Thank(name: "ZachariasFuchs")]
        ]
    ]
}
