//
//  FilterViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/21.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit
import os.log

class FilterViewController: UIViewController {
    
    var filterType: FilterType = .none
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var containerViewController: FilterTableViewController?

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "FilterTableViewController",
            let connectContainerViewController = segue.destination as? FilterTableViewController {
            containerViewController = connectContainerViewController
            containerViewController?.filterType = filterType
        }
        
        // Configure the destination view controller only when the done button is pressed.
        if let button = sender as? UIBarButtonItem, button === doneButton {
            if let year = containerViewController?.year,
                let term = containerViewController?.term,
                let coursesType = containerViewController?.coursesType {
                
                    UserDefaults.standard.set(year, forKey: "\(filterType.rawValue).year")
                    UserDefaults.standard.set(term, forKey: "\(filterType.rawValue).term")
                    UserDefaults.standard.set(coursesType, forKey: "\(filterType.rawValue).courseType")
                
            }
        } else {
            if #available(iOS 10.0, *) {
                os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            } else {
                // Fallback on earlier versions
            }
        }
        
    }

}
