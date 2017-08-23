//
//  GradeViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/17.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit

class GradeViewController: UIViewController,
    UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var gradesTableView: UITableView!
    
    // MARK: Properties
    var grades = [Grade]()
    var jwxt = JwxtApiClient.shared
    
    var year = UserDefaults.standard.object(forKey: "grade.year") as? String
    var term = UserDefaults.standard.object(forKey: "grade.term") as? String
    
    // MARK: Methods
    func loadData(completion: (() -> Void)? = nil) {
        year = UserDefaults.standard.object(forKey: "grade.year") as? String
        term = UserDefaults.standard.object(forKey: "grade.term") as? String
        if let year = year, let term = term,
            year != "全部" && term != "全部" {
            jwxt.getScoreList(year: Int(year.components(separatedBy: "-")[0])!, term: Int(term)!) { (success, object) in
                if success, let grades = object as? [Grade] {
                    self.grades.removeAll()
                    self.grades.append(contentsOf: grades)
                    DispatchQueue.main.async {
                        self.gradesTableView.reloadData()
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
                self.navigationItem.setTitle(title: "成绩", subtitle: "全部")
            } else {
                self.navigationItem.setTitle(title: "成绩", subtitle: "\(year), \(term)")
            }
            
        }
    }
    
    // MARK: Table Views
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grades.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "GradeTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GradeTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GradeTableViewCell.")
        }
        
        // populate the data
        let grade = grades[indexPath.row]
        
        cell.courseNameLabel.text = grade.name
        cell.creditLabel.text = "\(grade.credit)"
        cell.gpaLabel.text = "\(grade.gpa)"
        cell.gradeLabel.text = "\(grade.totalGrade)"
        cell.rankingInTeachingClassLabel.text = grade.rankingInTeachingClass
        cell.rankingInMajorClassLabel.text = grade.rankingInMajorClass
        
        return cell
    }
    
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
        
        gradesTableView.dataSource = self
        gradesTableView.delegate = self
        
        setupRefreshControl(tableView: gradesTableView)
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
    
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if let filterViewController = (segue.destination as? UINavigationController)?.topViewController as? FilterViewController {
            filterViewController.filterType = "grade"
        }
    }
    
    // MARK: Refresh Control
    
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
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.insertSubview(refreshControl, at: 0)
        }
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        loadData {
            refreshControl.endRefreshing()
        }
        
    }

}

