//
//  LocalNotification.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/25.
//
//  reference: mourodrigo
//  https://stackoverflow.com/questions/42688760/local-and-push-notifications-in-ios-9-and-10-using-swift3
//

import UIKit
import UserNotifications

class LocalNotification: NSObject, UNUserNotificationCenterDelegate {
    
    class func registerForLocalNotification(on application:UIApplication) {
        if (UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:)))) {
            
            if #available(iOS 10.0, *) {
                
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { (granted, error) in
                    if granted {
                        print("用户允许")
                    } else {
                        print("用户不允许")
                    }
                }
                
            } else {
                
                let notificationCategory:UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
                notificationCategory.identifier = "NOTIFICATION_CATEGORY"
                
                //registerting for the notification.
                application.registerUserNotificationSettings(UIUserNotificationSettings(types:[.sound, .alert, .badge], categories: nil))
            }
        }
    }
    
    class func dispatchlocalNotification(with title: String, body: String, userInfo: [AnyHashable: Any]? = nil, at timeInterval: TimeInterval) {
        
        let date = Date(timeIntervalSinceNow: timeInterval)
        
        if #available(iOS 10.0, *) {
            
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.categoryIdentifier = "update"
            
            if let info = userInfo {
                content.userInfo = info
            }
            
            content.sound = UNNotificationSound.default()
            
            let comp = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request)
            
        } else {
            
            let notification = UILocalNotification()
            notification.fireDate = date
            notification.alertTitle = title
            notification.alertBody = body
            
            if let info = userInfo {
                notification.userInfo = info
            }
            
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
            
        }
        
        print("WILL DISPATCH LOCAL NOTIFICATION AT ", date)
        
    }
}
