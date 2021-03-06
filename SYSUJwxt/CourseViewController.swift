//
//  CourseViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/17.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit

class CourseViewController: ListWithFilterViewController,
    UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var coursesTableView: UITableView!
    // MARK: Properties
    var courses = [Course]()
    var dayCourses = [Int: [Course]]()
    
    lazy var coursesExportManager = CoursesExportManager.shared
    
    // MARK: Methods
    func checkLogin() {
        if !jwxt.isLogin {
            // present the loginViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    override func loadData(completion: (() -> Void)? = nil) {
        loadSavedFilterData()
        jwxt.getCourseList(year: Int(year.components(separatedBy: "-")[0])!, term: Int(term)!) { (success, object) in
            if success, let courses = object as? [Course] {
                self.courses.removeAll()
                self.courses.append(contentsOf: courses)
                self.courses.sort(by: { $0.day.dayNumber < $1.day.dayNumber })
                self.countDays()
                DispatchQueue.main.async {
                    self.coursesTableView.reloadData()
                    completion?()
                }
            }
        }
    }
    
    func countDays() {
        dayCourses.removeAll()
        for course in courses {
            if dayCourses[course.day.dayNumber] != nil {
                dayCourses[course.day.dayNumber]?.append(course)
            } else {
                dayCourses[course.day.dayNumber] = [course]
            }
        }
    }
    
    // MARK: Table Views
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dayCourses.keys.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DayOfWeek.fromNumber(number: dayCourses.keys.sorted()[section])?.description
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = dayCourses.keys.sorted()[section]
        guard let count = dayCourses[key]?.count else {
            return 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "CourseTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CourseTableViewCell  else {
            fatalError("The dequeued cell is not an instance of CourseTableViewCell.")
        }
        
        // populate the data
        let key = dayCourses.keys.sorted()[indexPath.section]
        guard let course = dayCourses[key]?[indexPath.row] else {
            return cell
        }
        
        cell.courseNameLabel.text = course.name
        cell.locationLabel.text = course.location
        
        cell.timeLabel.text = "\(course.day.description)  \(course.startClass)-\(course.endClass)  \(course.duration)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if (segue.destination as? UINavigationController)?.topViewController is CourseExportTableViewController {
            coursesExportManager.courses = courses
            if let yearInt = Int(year.components(separatedBy: "-")[0]),
                let termInt = Int(term) {
                coursesExportManager.year = yearInt
                coursesExportManager.term = termInt
            }
        }
    }
    
    override func unwindToMainViewController(sender: UIStoryboardSegue) {
        super.unwindToMainViewController(sender: sender)
        
        if (sender.source as? UINavigationController)?.topViewController is CourseExportTableViewController {
            isUnwindingFromFilter = false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //checkLogin()
        
        setupRefreshControl(tableView: coursesTableView)
        
        coursesTableView.dataSource = self
        coursesTableView.delegate = self
        
        headerTitle = "课程"
        filterType = .course
        initSetup()
    }

}





