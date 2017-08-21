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
    
    
    // MARK: Methods
    func loadData() {
        jwxt.getScoreList(year: 2016, term: 2) { (success, object) in
            if success, let grades = object as? [Grade] {
                self.grades.removeAll()
                self.grades.append(contentsOf: grades)
                DispatchQueue.main.async {
                    self.gradesTableView.reloadData()
                }
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
        loadData()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        gradesTableView.dataSource = self
        gradesTableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

