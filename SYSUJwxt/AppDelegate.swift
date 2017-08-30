//
//  AppDelegate.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/17.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        if (launchOptions?[.localNotification]) != nil {
            UserDefaults.standard.set(true, forKey: "gradesUpdateNotificationLaunch")
        } else {
            UserDefaults.standard.set(false, forKey: "gradesUpdateNotificationLaunch")
        }
        
        if UserDefaults.standard.bool(forKey: "notify.isOn") {
            // check updates every 2 hours
            UIApplication.shared.setMinimumBackgroundFetchInterval(2400)
        } else {
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        
//        // check if the user has logged in and decide the initial
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        
//        if JwxtApiClient.shared.isLogin {
//            let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController")
//            self.window?.rootViewController = initialViewController
//        } else {
//            let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
//            self.window?.rootViewController = initialViewController
//        }
//        
//        self.window?.makeKeyAndVisible()
        
        UIWindow.appearance().tintColor = UIColor(colorLiteralRed: 33/255.0, green: 140/255.0, blue: 58/255.0, alpha: 1)
        
        UITabBar.appearance().tintColor = UIWindow.appearance().tintColor
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let jwxt = JwxtApiClient.shared
        
        LocalNotification.dispatchlocalNotification(with: "正在检查成绩", body: "...", at: 2)
        
        guard jwxt.isSavePassword else {
            // password not saved, not checking updates
            LocalNotification.dispatchlocalNotification(with: "密码没保存", body: "...", at: 5)
            completionHandler(.noData)
            return
        }
        
        // check if session is still valid
        
        let semaphore = DispatchSemaphore(value: 0)
        var isSuccess = false
        
        if jwxt.isLogin {
            
            jwxt.getInfo(completion: { (success, message) in
                if success {
                    
                    // valid
                    self.checkUpdates(jwxt: jwxt, completion: { (result) in
                        completionHandler(result)
                    })
                    
                    isSuccess = success
                    
                }
                semaphore.signal()
            })
            
        } else {
            
            // not logged in
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        if isSuccess {
            return
        }
        
        // login failed or not logged in, try relogin
        jwxt.login(completion: { (success, message) in
            if success {
                self.checkUpdates(jwxt: jwxt, completion: { (result) in
                    completionHandler(result)
                })
            } else {
                // login fail
                LocalNotification.dispatchlocalNotification(with: "重新登录失败", body: message as? String ?? "", at: 5)
                completionHandler(.noData)
            }
        })
        
    }
    
    // check grades updates
    func checkUpdates(jwxt: JwxtApiClient, completion: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let year = UserDefaults.standard.string(forKey: "notify.year"),
            let yearInt = Int(year.components(separatedBy: "-")[0]),
            let term = UserDefaults.standard.string(forKey: "notify.term") {
            
            let savedGradesDict = UserDefaults.standard.object(forKey: "monitorGrades") as? [String: Double] ?? [String: Double]()
            
            var savedGrades = [Grade]()
            for key in savedGradesDict.keys {
                savedGrades.append(Grade(name: key, totalGrade: savedGradesDict[key]!))
            }
            
            jwxt.getGradeList(year: yearInt, term: Int(term)!, completion: { (success, object) in
                if success, let grades = object as? [Grade] {
                    if Grade.areEquals(grades1: savedGrades, grades2: grades) {
                        
                        // no updates
                        
                        // for testing background fetch working correctly
                        let title = "成绩没更新😂"
                        _ = "什么也没有啊"
                        
                        let test = grades.map({ "\($0.name): \($0.totalGrade)" }).joined(separator: "\n")
                        print("\(test)")
                        
                        LocalNotification.dispatchlocalNotification(with: title, body: test, at: 5)
                        
                        completion(.noData)
                        
                    } else {
                        // grades updated! save it
                        let dictToSave = Dictionary(elements: grades.map({ ($0.name, $0.totalGrade) }))
                        UserDefaults.standard.set(dictToSave, forKey: "monitorGrades")
                        
                        // and notify updates
                        let diffGrades = Grade.getDiff(oldGrades: savedGrades, newGrades: grades)
                        
                        let title = "成绩更新了😄"
                        let body = diffGrades.map({ "\($0.name): \($0.totalGrade)" }).joined(separator: "\n")
                        
                        LocalNotification.dispatchlocalNotification(with: title, body: body, at: 5)
                        
                        switch UIApplication.shared.applicationState {
                            case .active:
                                //app is currently active, can update badges count here
                                UIApplication.shared.applicationIconBadgeNumber = 0
                                
                                break
                            case .inactive:
                                //app is transitioning from background to foreground (user taps notification), do what you need when user taps here
                                UIApplication.shared.applicationIconBadgeNumber = diffGrades.count
                                self.switchToGradeViewControllerAndUpdate()
                                
                                break
                            case .background:
                                //app is in background, if content-available key of your notification is set to 1, poll to your backend to retrieve data and update your interface here
                                self.switchToGradeViewControllerAndUpdate()
                                UIApplication.shared.applicationIconBadgeNumber = 1
                                
                                break
                        }
                        
                        completion(.newData)
                        
                    }
                }
            })
        }
    }
    
    func switchToGradeViewControllerAndUpdate() {
        if let presentedViewController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
            if let tabBarControllor = presentedViewController as? UITabBarController {
                DispatchQueue.main.async {
                    tabBarControllor.selectedIndex = 1 // the grade tab
                }
            } else {
                // some kind of settings/filters
                presentedViewController.dismiss(animated: false, completion: nil)
                DispatchQueue.main.async {
                    (UIApplication.shared.keyWindow?.rootViewController as? UITabBarController)?.selectedIndex = 1 // the grade tab
                }
            }
        }
    }

}

extension URLSession {
    
    func synchronousDataTask(with request: URLRequest) throws -> (data: Data?, response: HTTPURLResponse?) {
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var responseData: Data?
        var theResponse: URLResponse?
        var theError: Error?
        
        dataTask(with: request) { (data, response, error) -> Void in
            
            responseData = data
            theResponse = response
            theError = error
            
            semaphore.signal()
            
            }.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        if let error = theError {
            throw error
        }
        
        return (data: responseData, response: theResponse as! HTTPURLResponse?)
        
    }
    
}

extension Date {
    func addedBy(seconds: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
    }
}

extension Dictionary {
    init(elements: [(Key, Value)]) {
        self.init()
        for (key, value) in elements {
            updateValue(value, forKey: key)
        }
    }
}
