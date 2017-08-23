//
//  CourseViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/17.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit

class CourseViewController: UIViewController,
    UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var coursesTableView: UITableView!
    // MARK: Properties
    var courses = [Course]()
    var jwxt = JwxtApiClient.shared
    
    var year = UserDefaults.standard.object(forKey: "course.year") as? String
    var term = UserDefaults.standard.object(forKey: "course.term") as? String
    
    // MARK: Methods
    func checkLogin() {
        if !jwxt.isLogin {
            // present the loginViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func loadData(completion: (() -> Void)? = nil) {
        year = UserDefaults.standard.object(forKey: "course.year") as? String
        term = UserDefaults.standard.object(forKey: "course.term") as? String
        if let year = year, let term = term,
            year != "全部" && term != "全部" {
            jwxt.getCourseList(year: Int(year.components(separatedBy: "-")[0])!, term: Int(term)!) { (success, object) in
                if success, let courses = object as? [Course] {
                    self.courses.removeAll()
                    self.courses.append(contentsOf: courses)
                    self.courses.sort(by: { $0.day < $1.day })
                    DispatchQueue.main.async {
                        self.coursesTableView.reloadData()
                        completion?()
                    }
                }
            }
        }
    }
    
    func setTitle() {
        if var year = year, var term = term {
            if year != "全部" {
                year = "\(year) 学年"
            }
            if term != "全部" {
                term = "第 \(term) 学期"
            }
            if year == term {
                // "全部"
                self.navigationItem.setTitle(title: "课程", subtitle: "全部")
            } else {
                self.navigationItem.setTitle(title: "课程", subtitle: "\(year), \(term)")
            }
            
        }
    }
    
    // MARK: Table Views
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CourseTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CourseTableViewCell  else {
            fatalError("The dequeued cell is not an instance of CourseTableViewCell.")
        }
        
        // populate the data
        let course = courses[indexPath.row]
        
        cell.courseNameLabel.text = course.name
        cell.locationLabel.text = course.location
        
        if let dayString = course.dayString {
            cell.timeLabel.text = "\(dayString)  \(course.startTime)-\(course.endTime)  \(course.duration)"
        }
        
        return cell
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        
        if let filterViewController = (segue.destination as? UINavigationController)?.topViewController as? FilterViewController {
            filterViewController.filterType = "course"
        }
    }
    
    
    // MARK: Actions
    @IBAction func unwindToMainViewController(sender: UIStoryboardSegue) {
        print("unwinding")
        refreshControl.beginRefreshing()
        loadData {
            self.refreshControl.endRefreshing()
        }
        setTitle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //checkLogin()
        
        coursesTableView.dataSource = self
        coursesTableView.delegate = self
        
        setupRefreshControl(tableView: coursesTableView)
        refreshControl.beginRefreshing()
        loadData {
            self.refreshControl.endRefreshing()
        }
        setTitle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            refreshControl.endRefreshing()
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
        two.textColor = UIColor.darkGray
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



