//
//  GradeViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/17.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit

class GradeViewController: ListWithFilterViewController,
    UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var gradesTableView: UITableView!
    
    // MARK: Properties
    var grades = [Grade]()
    
    // MARK: Methods
    override func loadData(completion: (() -> Void)? = nil) {
        loadSavedFilterData()
        
        var years = [Int]()
        var terms = [Int]()
        
        if year == "全部" {
            years = jwxt.allYears
        } else {
            years = [Int(year.components(separatedBy: "-")[0])!]
        }
        
        if term == "全部" {
            terms = [1, 2, 3]
        } else {
            terms = [Int(term)!]
        }
        
        let coursesTypeValues = coursesType.map({ CourseType.fromString(string: $0) })
        
        jwxt.getGradeList(years: years, terms: terms) { (success, object) in
            if success, let grades = object as? [Grade] {
                self.grades.removeAll()
                // filter a courseType and append to the table data
                let filteredGrades = grades.filter({ coursesTypeValues.contains($0.courseType) })
                let sortedFilteredGrades = filteredGrades.sorted(by: { (grade1, grade2) -> Bool in
                    if grade1.year > grade2.year {
                        return true
                    } else if grade1.year == grade2.year {
                        if grade1.term > grade2.term {
                            return true
                        } else if grade1.term == grade2.term {
                            return grade1.name > grade2.name
                        }
                    }
                    return false
                })
                self.grades.append(contentsOf: sortedFilteredGrades)
                DispatchQueue.main.async {
                    self.gradesTableView.reloadData()
                    completion?()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.setSelected(false, animated: true)
            cell.isSelected = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefreshControl(tableView: gradesTableView)
        
        gradesTableView.dataSource = self
        gradesTableView.delegate = self
        
        headerTitle = "成绩"
        filterType = .grade
        initSetup()
    }
    
    override func unwindToMainViewController(sender: UIStoryboardSegue) {
        super.unwindToMainViewController(sender: sender)
        
        // save current grades if notification is on
        if let _ = (sender.source as? UINavigationController)?.topViewController as? NotifySettingTableViewController,
            let year = UserDefaults.standard.string(forKey: "notify.year"),
            let yearInt = Int(year.components(separatedBy: "-")[0]),
            let term = UserDefaults.standard.string(forKey: "notify.term") {
            // save current grades
            jwxt.getGradeList(years: [yearInt], terms: [Int(term)!], completion: { (success, object) in
                if success, let grades = object as? [Grade] {
                    UserDefaults.standard.set(grades, forKey: "monitorGrades")
                }
            })
        }
    }

}

