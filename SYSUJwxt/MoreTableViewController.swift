//
//  MoreTableViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/24.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit
import SafariServices

class MoreTableViewController: UITableViewController {
    
    // MARK: Properties
    var jwxt = JwxtApiClient.shared
    
    // MARK: Constants
    struct Constants {
        static let DesignerWebsite = "https://www.behance.net/hula3"
        static let GitHubLink = "https://github.com/benwwchen/sysujwxt-ios"
    }
    
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
            
            if indexPath.section == 2 {
                // about section
                if indexPath.row == 0 {
                    // designer
                    let sfVC = SFSafariViewController(url: URL(string: Constants.DesignerWebsite)!)
                    self.present(sfVC, animated: true, completion: nil)
                }
                if indexPath.row == 1 {
                    // GitHub
                    let sfVC = SFSafariViewController(url: URL(string: Constants.GitHubLink)!)
                    self.present(sfVC, animated: true, completion: nil)
                }
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
                case "TimetableSegue":
                    destination.title = "课程时间表"
                    destination.htmlFileName = "timetable"
                case "DesriptionSegue":
                    destination.title = "说明"
                    destination.htmlFileName = "explanation"
                    break
                case "AboutSegue":
                    destination.title = "关于"
                    destination.htmlFileName = "about"
                    break
                case "AcknowlegementSegue":
                    destination.title = "致谢"
                    destination.htmlFileName = "acknowledgement"
                    break
                default:
                    break
            }
            
        }
        
    }

}
