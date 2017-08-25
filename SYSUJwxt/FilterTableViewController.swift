//
//  FilterTableViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/21.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit

enum FilterType: String {
    case course = "course"
    case grade = "grade"
    case none = ""
}

class FilterTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Views
    
    // year
    var pickerView: UIPickerView?
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var yearTableViewCell: UITableViewCell!
    // term
    @IBOutlet weak var termSegmentedControl: UISegmentedControl!
    
    // MARK: Properties
    
    // filter name
    var filterType: FilterType = .none

    // editing
    var lastSelectedYear: String = SelectTypes.All
    
    // selected
    var year: String = SelectTypes.All
    var term: String = SelectTypes.All
    var coursesType = [String]()
    
    // choices
    var years = [String]()
    let allCourseTypes = ["公必", "专必", "专选", "公选"]
    
    // MARK: Constants
    struct SelectTypes {
        static let All = "全部"
    }
    
    // MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load filter data
        loadFilterData()
        
        // setup the picker for year selector
        initPickerData()
        initPickerView()
        
    }
    
    // load saved data
    func loadFilterData() {
        if let year = UserDefaults.standard.object(forKey: "\(filterType.rawValue).year") as? String {
            self.year = year
        }
        if let term = UserDefaults.standard.object(forKey: "\(filterType.rawValue).term") as? String {
            self.term = term
        }
        if let coursesType = UserDefaults.standard.object(forKey: "\(filterType.rawValue).courseType") as? [String]  {
            self.coursesType = coursesType
        }
        
        // populate the data
        if filterType == .course {
            // no "all" option for courses
            termSegmentedControl.removeSegment(at: 3, animated: false)
        }
        yearLabel.text = year
        if let termIndex = termIndex(from: term) {
            termSegmentedControl.selectedSegmentIndex = termIndex
        }
        
        if filterType == .grade {
            for i in 1..<tableView.numberOfRows(inSection: 2) {
                if let cell = tableView.cellForRow(at: IndexPath(row: i, section: 2)),
                    let labelText = cell.textLabel?.text,
                    coursesType.contains(labelText) {
                    cell.accessoryType = .checkmark
                }
            }
            
            if coursesType.count == 4 {
                tableView.cellForRow(at: IndexPath(row: 0, section: 2))?.accessoryType = .checkmark
                let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2))
                print ("\(String(describing: cell?.accessoryType))")
            }
        }
    }
    
    // year picker
    
    func initPickerData() {
        years = [SelectTypes.All]
        
        if filterType == .course {
            // no "all" option for courses
            years.removeAll()
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        if let currentYear = Int(dateFormatter.string(from: Date())) {
            let entranceYear = JwxtApiClient.shared.grade
            for year in (entranceYear...currentYear).reversed() {
                years.append("\(year)-\(year+1)")
            }
        }
    }
    
    func initPickerView() {
        let newPickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height / 3.0))
        
        newPickerView.backgroundColor = .white
        
        newPickerView.showsSelectionIndicator = true
        newPickerView.delegate = self
        newPickerView.dataSource = self
        print(years.index(of: year)!)
        newPickerView.selectRow(years.index(of: year)!, inComponent: 0, animated: false)
        
        pickerView = newPickerView
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(cancelPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        yearTextField.inputView = pickerView
        yearTextField.inputAccessoryView = toolBar
        
    }
    
    // MARK: - Picker view data source
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        year = years[row]
        yearLabel.text = year
        yearTextField.text = year
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return years[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func donePicker(sender: UIBarButtonItem) {
        yearTextField.resignFirstResponder()
        yearTableViewCell.setSelected(false, animated: true)
    }
    
    func cancelPicker(sender: UIBarButtonItem) {
        yearTextField.resignFirstResponder()
        yearTableViewCell.setSelected(false, animated: true)
        
        year = lastSelectedYear
        yearTextField.text = year
        yearLabel.text = year
    }
    
    // term
    @IBAction func termControlValueChanged(_ sender: UISegmentedControl) {
        if let title = sender.titleForSegment(at: sender.selectedSegmentIndex) {
            term = title
        }
    }
    
    func termIndex(from title: String) -> Int? {
        if title == "1" || title == "2" || title == "3" {
            return Int(title)! - 1
        }
        if title == SelectTypes.All {
            return 3
        }
        return nil
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // show picker for year selection
        if let cell = tableView.cellForRow(at: indexPath), cell.reuseIdentifier == "yearCell" {
            lastSelectedYear = year
            yearTextField.becomeFirstResponder()
        }
        
        // select course type
        if indexPath.section == 2,
            let cell = tableView.cellForRow(at: indexPath),
            let labelText = cell.textLabel?.text {
                
            if labelText == SelectTypes.All {
                
                var typeToChange = UITableViewCellAccessoryType.none
                
                if coursesType.count == 4 {
                    coursesType.removeAll()
                } else {
                    coursesType = allCourseTypes
                    typeToChange = UITableViewCellAccessoryType.checkmark
                }
                
                for i in 1..<tableView.numberOfRows(inSection: 2) {
                    tableView.cellForRow(at: IndexPath(row: i, section: 2))?.accessoryType = typeToChange
                }
                
            } else {
                
                if !coursesType.contains(labelText) {
                    cell.accessoryType = .checkmark
                    coursesType.append(labelText)
                } else {
                    cell.accessoryType = .none
                    coursesType.remove(at: coursesType.index(of: labelText)!)
                }
            }
            
            if coursesType.count == 4 {
                tableView.cellForRow(at: IndexPath(row: 0, section: 2))?.accessoryType = .checkmark
            } else {
                tableView.cellForRow(at: IndexPath(row: 0, section: 2))?.accessoryType = .none
            }
            
            cell.setSelected(false, animated: true)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if filterType == .course {
            return 2
        } else {
            return 3
        }
    }

}
