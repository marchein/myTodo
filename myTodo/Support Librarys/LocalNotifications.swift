//
//  LocalNotifications.swift
//  myTodo
//
//  Created by Marc Hein on 08.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit
import UserNotifications

class LocalNotification: NSObject, UNUserNotificationCenterDelegate {
    
    static let center = UNUserNotificationCenter.current()
    
    class func registerForLocalNotification(on application:UIApplication) {
        //Notifications get posted to the function (delegate):  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void)"
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            
            guard error == nil else {
                //Display Error.. Handle Error.. etc..
                return
            }
            
            if granted {
                //Do stuff here..
                
                //Register for RemoteNotifications. Your Remote Notifications can display alerts now :)
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                //Handle user denying permissions..
            }
        }
        
        //Register for remote notifications.. If permission above is NOT granted, all notifications are delivered silently to AppDelegate.
        application.registerForRemoteNotifications()
    }
    
    class func dispatchlocalNotification(with todo: Todo) {
        if (todo.date! > Date()) {
            removeNotification(for: todo)
            let content = UNMutableNotificationContent()
            content.title = todo.title!
            content.body = "Is due \(getDateOf(date: todo.date, option: .both)!)"
            content.categoryIdentifier = "myTodo"
            content.badge = 1
            content.sound = UNNotificationSound.default
            
            let comp = Calendar.current.dateComponents([.hour, .minute], from: todo.date!)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: false)
            let identifier = generateTodoIdentifier(for: todo)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            center.add(request)
            
            print("WILL DISPATCH LOCAL NOTIFICATION WITH IDENTIFIER \(identifier) AT ", todo.date!)
        }
    }
    
    class func removeNotification(for todo: Todo) {
        let identifier = generateTodoIdentifier(for: todo)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("LOCAL NOTIFICATION FOR IDENTIFIER \(identifier) HAS BEEN CANCELED")
    }
    
    class func generateTodoIdentifier(for todo: Todo) -> String {
        return "myTodo-\(todo.objectID.uriRepresentation().absoluteString)"
    }
    
    class func transformIdentifierToObjectId(for identifier: String) -> String {
        return identifier.replacingOccurrences(of: "myTodo-", with: "")
    }
}
