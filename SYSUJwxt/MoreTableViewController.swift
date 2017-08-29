//
//  MoreTableViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/24.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit

class MoreTableViewController: UITableViewController {
    
    // MARK: Properties
    var jwxt = JwxtApiClient.shared
    
    
    // MARK: Views

    @IBOutlet weak var savePasswordSwitch: UISwitch!
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    // MARK: Actions
    @IBAction func savePasswordSwitchValueChanged(_ sender: UISwitch) {
        jwxt.isSavePassword = sender.isOn
    }
    
    
    // MARK: Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.setSelected(false, animated: true)
            
            if cell === logoutCell {
                jwxt.isSavePassword = false
                jwxt.isLogin = false
                jwxt.logout()
                performSegue(withIdentifier: "unwindToLoginViewController", sender: self)
            }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        savePasswordSwitch.setOn(jwxt.isSavePassword, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.destination.restorationIdentifier == "MoreDetailViewController",
            let destination = segue.destination as? MoreDetailWebViewController,
            let identifier = segue.identifier {
            
            switch identifier {
                case "DesriptionSegue":
                    destination.title = "说明"
                    destination.url = "https://blog.bencww.com"
                    break
                case "AboutSegue":
                    destination.title = "关于"
                    break
                case "AcknowlegementSegue":
                    destination.title = "致谢"
                    break
                default:
                    break
            }
            
        }
        
    }

}
