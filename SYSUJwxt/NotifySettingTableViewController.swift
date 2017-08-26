//
//  NotifySettingTableViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/24.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit
import os.log

class NotifySettingTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    var year: String = ""
    var term: String = ""
    var isNotifyOn: Bool = UserDefaults.standard.bool(forKey: "notify.isOn") 
    
    // choices
    var years = [String]()
    
    // editing
    var lastSelectedYear: String = ""
    
    var pickerView: UIPickerView?
    
    @IBOutlet weak var yearTableViewCell: UITableViewCell!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var notifySwitch: UISwitch!
    @IBOutlet weak var termSegmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load saved settings
        
        // try to get the saved year
        if let savedYear = UserDefaults.standard.object(forKey: "notify.year") as? String {
            year = savedYear
        } else {
            // no saved value, init it as the current year and save it
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            if let yearInt = Int(dateFormatter.string(from: Date())) {
                year = "\(yearInt)-\(yearInt+1)"
            }
        }
        
        // try to get the saved term
        if let savedTerm = UserDefaults.standard.object(forKey: "notify.term") as? String {
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
        }
        
        // switch
        notifySwitch.isOn = isNotifyOn
        
        // setup the picker for year selector
        initPickerData()
        initPickerView()
        
        // populate the data
        yearLabel.text = year
        termSegmentedControl.selectedSegmentIndex = Int(term)! - 1
        
    }
    
    // year picker
    
    func initPickerData() {
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
    
    @IBAction func termSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        if let title = sender.titleForSegment(at: sender.selectedSegmentIndex) {
            term = title
        }
    }
    

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isNotifyOn {
            return 2
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show picker for year selection
        if let cell = tableView.cellForRow(at: indexPath), cell.reuseIdentifier == "yearCell" {
            lastSelectedYear = year
            yearTextField.becomeFirstResponder()
        }
    }
    
    // MARK: Actions
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        isNotifyOn = sender.isOn
        if isNotifyOn {
            LocalNotification.registerForLocalNotification(on: UIApplication.shared)
        }
        tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        if let button = sender as? UIBarButtonItem, button === saveButton {
            
            UserDefaults.standard.set(isNotifyOn, forKey: "notify.isOn")
            UserDefaults.standard.set(year, forKey: "notify.year")
            UserDefaults.standard.set(term, forKey: "notify.term")
            
            if isNotifyOn {
                // check updates every 2 hours
                UIApplication.shared.setMinimumBackgroundFetchInterval(2400)
            } else {
                UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
            }
            
        } else {
            if #available(iOS 10.0, *) {
                os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            } else {
                // Fallback on earlier versions
            }
        }
        
    }

}

extension UITableView {
    func reloadData(with animation: UITableViewRowAnimation) {
        reloadSections(IndexSet(integersIn: 0..<numberOfSections), with: animation)
    }
}
