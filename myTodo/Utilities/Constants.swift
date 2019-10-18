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
    // how many todos are added?
    static let todosAdded = "todosAdded"
}

struct myTodoIAP {
    #if targetEnvironment(macCatalyst)
        static let smallTip = "de.marc_hein.myTodo.mac.tip.small"
        static let mediumTip = "de.marc_hein.myTodo.mac.tip.medium"
        static let largeTip = "de.marc_hein.myTodo.mac.tip.large"
    #else
        static let smallTip = "de.marc_hein.myTodo.tip.small"
        static let mediumTip = "de.marc_hein.myTodo.tip.medium"
        static let largeTip = "de.marc_hein.myTodo.tip.large"
    #endif
    
    static let allTips = [myTodoIAP.smallTip, myTodoIAP.mediumTip, myTodoIAP.largeTip]
}

struct myTodoSegue {
    static let showDetail = "showDetail"
    static let addTodo = "addSegue"
    static let edit = "editSegue"
    static let quickEdit = "quickEditSegue"
    static let emptyDetailView = "emptyDetail"
    static let about = "aboutSegue"
}

struct myTodoShortcut {
    static let add3dTouch = "de.marc-hein.myTodo.add"
}

struct myTodo {
    #if targetEnvironment(macCatalyst)
        static let appStoreId = "1484062619"
    #else
        static let appStoreId = "1441790770"
    #endif
    static let twitterName = "myTodo_app"
    static let mailAdress = "dev@marc-hein.de"
    static let website = "https://marc-hein.de/"
    static let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    static let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    
    static let defaultAppIcon = "default"
    static var appIcons = AppIcons(icons: [
        AppIcon(iconName: nil, iconTitle: "myTodo - " + NSLocalizedString("icon_light", comment: "")),
        AppIcon(iconName: "myTodo2019dark", iconTitle: "myTodo - "  + NSLocalizedString("icon_dark", comment: "")),
        AppIcon(iconName: "myTodo2", iconTitle: "myTodo (2014)"),
        AppIcon(iconName: "myTodo1", iconTitle: "myTodo (2013)")
    ])
    static let thanksItems = [
        ["header": "Frameworks",
         "items": [Thank(name: "IQKeyboardManager", url: "https://github.com/hackiftekhar/IQKeyboardManager"),
                   Thank(name: "JGProgressHUD", url: "https://github.com/JonasGessner/JGProgressHUD"),
                   Thank(name: "MGSwipeTableCell", url: "https://github.com/MortimerGoro/MGSwipeTableCell")]],
        ["header": NSLocalizedString("Developers", comment: ""),
         "items": [Thank(name: "ChristianSelig")]],
        ["header": NSLocalizedString("Beta testers", comment: ""),
         "items": [Thank(name: "BugsB"),
                   Thank(name: "itsmelenni"),
                   Thank(name: "ZachariasFuchs")]
        ]
    ]
    
    static let askForReviewAt = 5
}
