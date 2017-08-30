//
//  AlertExtension.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/30.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit

struct AlertTitles {
    static let Default = "确认"
    static let Settings = "设置"
    static let Cancel = "取消"
    static let PermissionDenied = "没有权限"
    static let CalendarPermissionRequest = "请到设置里开启日历访问权限"
    static let NotificationPermissionRequest = "请到设置里开启通知提醒"
}

extension UIViewController {
    
    // display an alert dialog
    func alert(title: String, message: String, titleDefault: String? = nil, titleCancel: String? = nil, handler: ((UIAlertAction) -> Void)? = nil) {
        
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if titleDefault != nil {
            alertViewController.addAction(UIAlertAction(title: titleDefault, style: .default, handler: { (action) in
                handler?(action)
            }))
        }
        
        if titleCancel != nil {
            alertViewController.addAction(UIAlertAction(title: titleCancel, style: .cancel, handler: { (action) in
                handler?(action)
            }))
        }
        
        self.present(alertViewController, animated: true, completion: nil)
        
    }
}
