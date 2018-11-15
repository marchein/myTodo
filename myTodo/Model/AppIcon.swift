//
//  AppIcon.swift
//  myTodo
//
//  Created by Marc Hein on 15.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import Foundation

struct AppIcon {
    let iconName: String?
    let iconTitle: String
}

struct AppIcons {
    let icons: [AppIcon]
    
    func contains(iconName: String?) -> Bool {
        for currentIcon in icons {
            if iconName == currentIcon.iconName {
                return true
            }
        }
        return false
    }
    
    func count() -> Int {
        return icons.count
    }
    
    func getIcon(for index: Int) -> AppIcon? {
        if index >= 0 && index < icons.count {
            return icons[index]
        } else {
            return nil
        }
    }
}
