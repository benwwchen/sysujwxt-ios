//
//  FilterViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/21.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {

    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
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
        if segue.identifier == "FilterTableViewController",
            let connectContainerViewController = segue.destination as? FilterTableViewController {
            containerViewController = connectContainerViewController
            
        }
    }

}
