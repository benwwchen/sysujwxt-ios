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
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var netIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginFormStackView: UIStackView!
    @IBOutlet weak var loadingStackView: UIStackView!
    @IBOutlet weak var savePasswordSwitch: UISwitch!
    
    
    // MARK: Properties
    var jwxt = JwxtApiClient.shared
    
    // MARK: Methods
    
    func tryLogin(netId: String, password: String) {
        // try login
        loginFormStackView.setView(hidden: true)
        loadingStackView.setView(hidden: false)
        loadingIndicator.startAnimating()
        jwxt.netId = netId
        jwxt.password = password
        jwxt.login { (success, message) in
            DispatchQueue.main.async {
                if success {
                    self.continueToMainVC()
                } else {
                    self.messageLabel.setView(hidden: false)
                    self.loginFormStackView.setView(hidden: false)
                    self.loadingIndicator.stopAnimating()
                    self.loadingStackView.setView(hidden: true)
                }
            }
        }
    }
    
    func tryAutoLogin() {
        if jwxt.getSavedPassword() {
            // session saved before, check if still valid
            loginFormStackView.setView(hidden: true)
            //loadingIndicator.startAnimating()
            jwxt.login(completion: { (success, message) in
                DispatchQueue.main.async {
                    if success {
                        self.continueToMainVC()
                    } else {
                        self.loginFormStackView.setView(hidden: false)
                        self.loadingIndicator.stopAnimating()
                    }
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up views
        loadingIndicator.hidesWhenStopped = true
        loadingStackView.setView(hidden: true)
        messageLabel.setView(hidden: true)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(doneInput))]
        toolbar.sizeToFit()
        passwordTextField.inputAccessoryView = toolbar
        
        savePasswordSwitch.isOn = jwxt.isSavePassword
        
        // try auto login if password saved
        if jwxt.isSavePassword {
            tryAutoLogin()
        }
        
        // Handle the text field’s user input through delegate callbacks.
        netIdTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func doneInput(sender: UIBarButtonItem) {
        passwordTextField.resignFirstResponder()
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
        
        tryLogin(netId: netId, password: password)
    }
    
    @IBAction func savePasswordSwitchValueChanged(_ sender: UISwitch) {
        
        jwxt.isSavePassword = sender.isOn
        
    }
    
    @IBAction func unwindToLoginViewController(sender: UIStoryboardSegue) {
        
        messageLabel.isHidden = true
        loginFormStackView.setView(hidden: false)
        loadingStackView.setView(hidden: true)
        savePasswordSwitch.setOn(jwxt.isSavePassword, animated: true)
        
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
