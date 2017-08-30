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
    
    class func registerForLocalNotification(on application:UIApplication, currentViewController: UIViewController) {
        if (UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:)))) {
            
            if #available(iOS 10.0, *) {
                
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { (granted, error) in
                    if granted {
                        print("用户允许")
                    } else {
                        // Alert fail and navigate user to settings
                        currentViewController.alert(title: AlertTitles.PermissionDenied, message: AlertTitles.NotificationPermissionRequest, titleDefault: AlertTitles.Settings, titleCancel: AlertTitles.Cancel, handler: { (action) in
                            DispatchQueue.main.async {
                                switch action.style {
                                case .default:
                                    
                                    // go to settings
                                    UIApplication.shared.open(URL(string: "App-prefs:root=com.bencww.SYSUJwxt")!, completionHandler: { (success) in
                                        currentViewController.dismiss(animated: true, completion: nil)
                                    })
                                    
                                    break
                                case .cancel:
                                    currentViewController.dismiss(animated: true, completion: nil)
                                    break
                                default: break
                                }
                            }
                        })
                    }
                }
                
            } else {
                
                let notificationCategory:UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
                notificationCategory.identifier = "NOTIFICATION_CATEGORY"
                
                //registerting for the notification.
                application.registerUserNotificationSettings(UIUserNotificationSettings(types:[.sound, .alert, .badge], categories: nil))
                
                
                // check if the notification setting is on
                let notificationType = UIApplication.shared.currentUserNotificationSettings?.types
                
                if notificationType?.rawValue == 0 {
                    currentViewController.alert(title: AlertTitles.PermissionDenied, message: AlertTitles.NotificationPermissionRequest, titleDefault: AlertTitles.Settings, titleCancel: AlertTitles.Cancel, handler: { (action) in
                        DispatchQueue.main.async {
                            switch action.style {
                            case .default:
                                
                                // go to settings
                                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                                
                                break
                            case .cancel:
                                currentViewController.dismiss(animated: true, completion: nil)
                                break
                            default: break
                            }
                        }
                    })
                }
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
