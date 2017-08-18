//
//  SecondViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/17.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var detailLabel: UILabel!
    
    var jwxt = JwxtApiClient.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jwxt.getScoreList(year: 2016, term: 2) { (success, object) in
            if success {
                
            }
            DispatchQueue.main.async {
                self.detailLabel.text = object as? String
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

