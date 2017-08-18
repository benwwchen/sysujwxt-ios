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
    
    // MARK: Properties
    var jwxt = JwxtApiClient.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                self.performSegue(withIdentifier: "unwindSegueToMain", sender: self)
            }
        }
    
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
    }
    

}
