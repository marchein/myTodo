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
    
    class func registerForLocalNotification(on application: UIApplication) {
        //Notifications get posted to the function (delegate):  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void)"
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            
            guard error == nil else {
                //Display Error.. Handle Error.. etc..
                return
            }
            
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        application.registerForRemoteNotifications()
    }
    
    class func dispatchlocalNotification(with todo: Todo) {
        if (todo.date! > Date()) {
            removeNotification(for: todo)
            let content = UNMutableNotificationContent()
            content.title = todo.title!
            content.body = "\(NSLocalizedString("Is due", comment: "")): \(getDateOf(date: todo.date, option: .both)!) \(NSLocalizedString("time unit", comment: ""))"
            content.categoryIdentifier = "myTodo"
            content.badge = 1
            content.sound = UNNotificationSound.default
            
            let comp = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: todo.date!)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: false)
            let identifier = generateTodoIdentifier(for: todo)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            center.add(request)
        }
    }
    
    class func removeNotification(for todo: Todo) {
        let identifier = generateTodoIdentifier(for: todo)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    class func generateTodoIdentifier(for todo: Todo) -> String {
        return "myTodo-\(todo.objectID.uriRepresentation().absoluteString)"
    }
    
    class func transformIdentifierToObjectId(for identifier: String) -> String {
        return identifier.replacingOccurrences(of: "myTodo-", with: "")
    }
}
