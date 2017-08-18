//
//  FirstViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/17.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController,
    UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var coursesTableView: UITableView!
    // MARK: Properties
    var courses = [Course]()
    var jwxt = JwxtApiClient.shared
    
    
    // MARK: Methods
    func checkLogin() {
        if !jwxt.isLogin {
            // present the loginViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func loadData() {
        jwxt.getCourseList(year: 2016, term: 1) { (success, object) in
            if success, let courses = object as? [Course] {
                self.courses.removeAll()
                self.courses.append(contentsOf: courses)
                DispatchQueue.main.async {
                    self.coursesTableView.reloadData()
                }
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
        cell.timeLabel.text = "\(course.startTime)-\(course.endTime)"
        cell.dayLabel.text = "\(course.day)"
        cell.durationLabel.text = course.duration
        
        return cell
    }
    
    // MARK: Actions
    @IBAction func unwindToMainViewController(sender: UIStoryboardSegue) {
        loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //checkLogin()
        loadData()
        coursesTableView.dataSource = self
        coursesTableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

