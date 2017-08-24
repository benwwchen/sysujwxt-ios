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
    var jwxt = JwxtApiClient.shared
    
    // MARK: Methods
    override func loadData(completion: (() -> Void)? = nil) {
        loadSavedFilterData()
        if year != "全部" && term != "全部" {
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
        // TODO: handle "all" options and fitler courseType
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

}

