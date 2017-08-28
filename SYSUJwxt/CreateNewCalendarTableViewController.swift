//
//  CreateNewCalendarTableViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/29.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit

class CreateNewCalendarTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
    }

}
