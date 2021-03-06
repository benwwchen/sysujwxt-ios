//
//  ListWithFilterViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/24.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit

class ListWithFilterViewController: UIViewController {

    // MARK: Properties
    var headerTitle: String = ""
    var filterType: FilterType = .none
    let jwxt = JwxtApiClient.shared
    var isUnwindingFromFilter = false
    
    // get the saved value or init it
    var year: String = ""
    var term: String = ""
    var coursesType = [String]()
    
    // MARK: Methods
    func loadSavedFilterData() {
        // try to get the saved year
        if let savedYear = UserDefaults.standard.object(forKey: "\(self.filterType.rawValue).year") as? String {
            year = savedYear
        } else {
            // no saved value, init it as the current year and save it
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            if let yearInt = Int(dateFormatter.string(from: Date())) {
                year = "\(yearInt)-\(yearInt+1)"
            }
            UserDefaults.standard.set(year, forKey: "\(self.filterType.rawValue).year")
        }
        
        // try to get the saved term
        if let savedTerm = UserDefaults.standard.object(forKey: "\(self.filterType.rawValue).term") as? String {
            term = savedTerm
        } else {
            // no saved value, init it as the current term and save it
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "mm"
            if let month = Int(dateFormatter.string(from: Date())),
                month >= 8 || month <= 2 {
                term = "1"
            } else {
                term = "2"
            }
            UserDefaults.standard.set(term, forKey: "\(self.filterType.rawValue).term")
        }
        
        // try to get the saved coursesType
        if let savedCoursesType = UserDefaults.standard.object(forKey: "\(self.filterType.rawValue).courseType") as? [String] {
            coursesType = savedCoursesType
        }
    }
    
    func loadData(completion: (() -> Void)? = nil) {
        // must be overided in the subclass
    }

    func setTitle() {
        var displayYear: String, displayTerm: String
        if year != "全部" {
            displayYear = "\(year) 学年"
        } else {
            displayYear = "全部学年"
        }
        if term != "全部" {
            displayTerm = "第 \(term) 学期"
        } else {
            displayTerm = "全部学期"
        }
        if year == term {
            // "全部"
            self.navigationItem.setTitle(title: headerTitle, subtitle: "全部")
        } else {
            self.navigationItem.setTitle(title: headerTitle, subtitle: "\(displayYear), \(displayTerm)")
        }
    }
    
    func initSetup() {
        refreshControl.beginRefreshingManually()
        setTitle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isUnwindingFromFilter {
            refreshControl.beginRefreshingManually()
            isUnwindingFromFilter = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    @IBAction func unwindToMainViewController(sender: UIStoryboardSegue) {
        
        loadSavedFilterData()
        setTitle()
        
        isUnwindingFromFilter = true
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIView.appearance().tintColor
        
        return refreshControl
    }()
    
    // refresh controll
    func setupRefreshControl(tableView: UITableView) {
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        loadData {
            self.dispatchDelay(delay: 0.35, closure: {
                self.refreshControl.endRefreshing()
            })
        }
        
    }
    
    func dispatchDelay(delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: closure)
    }
    

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        
        if let filterViewController = (segue.destination as? UINavigationController)?.topViewController as? FilterViewController {
            filterViewController.filterType = filterType
        }
    }

}

// custom navigation view with subtitle
extension UINavigationItem {
    
    func setTitle(title:String, subtitle:String) {
        
        let one = UILabel()
        one.text = title
        one.font = UIFont.systemFont(ofSize: 17)
        one.textAlignment = .center
        one.sizeToFit()
        
        let two = UILabel()
        two.text = subtitle
        two.font = UIFont.systemFont(ofSize: 12)
        two.textAlignment = .center
        two.textColor = UIColor.gray
        two.sizeToFit()
        
        let stackView = UIStackView(arrangedSubviews: [one, two])
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        stackView.alignment = .center
        
        let width = max(one.frame.size.width, two.frame.size.width)
        stackView.frame = CGRect(x: 0, y: 0, width: width, height: 35)
        
        self.titleView = stackView
    }
    
}

extension UIRefreshControl {
    func beginRefreshingManually() {
        if let scrollView = superview as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height), animated: true)
        }
        beginRefreshing()
        sendActions(for: .valueChanged)
    }
}
