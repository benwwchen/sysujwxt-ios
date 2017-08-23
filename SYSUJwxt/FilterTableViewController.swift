//
//  FilterTableViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/21.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit

enum Term: String {
    case one = "1"
    case two = "2"
    case three = "3"
    case all = "全部"
    
    var description: String {
        get {
            return self.rawValue
        }
    }
}

class FilterTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Views
    var pickerView: UIPickerView?
    @IBOutlet weak var yearTextField: UITextField!
    
    // MARK: Properties
    
    // selected
    var year: String = "所有"
    
    // choices
    var years = [String]()
    var term: Term = .all
    
    // MARK: Methods
    
    func initPickerData() {
        years = ["所有", "2016-2017", "2015-2016", "2014-2015"]
    }
    
    func initPickerView() {
        let newPickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height / 3.0))
        
        newPickerView.backgroundColor = .white
        
        newPickerView.showsSelectionIndicator = true
        newPickerView.delegate = self
        newPickerView.dataSource = self
        
        pickerView = newPickerView
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        yearTextField.allowsEditingTextAttributes = false
        yearTextField.inputView = pickerView
        yearTextField.inputAccessoryView = toolBar
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initPickerData()
        initPickerView()
        
    }
    
    // MARK: - Picker view data source
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        year = years[row]
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
    }

    // MARK: - Table view data source


    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
