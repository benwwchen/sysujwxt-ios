//
//  LoginViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/17.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit
import os.log

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var netIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: Properties
    var jwxt = JwxtApiClient.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if jwxt.getSavedPassword() {
            // session saved before, check if still valid
            netIdTextField.setView(hidden: true)
            passwordTextField.setView(hidden: true)
            loginButton.isHidden = true
            loadingIndicator.startAnimating()
            jwxt.login(completion: { (success, message) in
                if success {
                    self.continueToMainVC()
                } else {
                    self.netIdTextField.setView(hidden: false)
                    self.passwordTextField.setView(hidden: false)
                    self.loginButton.setView(hidden: false)
                    self.loadingIndicator.stopAnimating()
                }
            })
        }
        // Handle the text field’s user input through delegate callbacks.
        netIdTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === netIdTextField {
            passwordTextField.becomeFirstResponder()
        }
    }
    
    // MARK: Actions
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        guard let netId = netIdTextField.text, !netId.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else {
                
            // empty field
            return
        }
        
        jwxt.netId = netId
        jwxt.password = password
        jwxt.login { (success, message) in
            if success {
                self.continueToMainVC()
            }
        }
    
    }
    
    // MARK: - Navigation
    
    func continueToMainVC() {
        if self.isBeingPresented {
            // unwind to MainViewController
            self.performSegue(withIdentifier: "unwindSegueToMain", sender: self)
        } else {
            // present the MainViewController
            self.performSegue(withIdentifier: "segueToMainAfterLogin", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }

}

extension UIViewController {
    var isModal: Bool {
        if let index = navigationController?.viewControllers.index(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController  {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
}

extension UIView {
    func setView(hidden: Bool) {
        UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: { _ in
            self.isHidden = hidden
        }, completion: nil)
    }
}
