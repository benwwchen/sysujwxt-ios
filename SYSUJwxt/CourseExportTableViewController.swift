//
//  CourseExportTableViewController.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/28.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class CourseExportTableViewController: UITableViewController, EKCalendarChooserDelegate {
    
    var calendars: [EKCalendar] = [EKCalendar]()
    
    lazy var calendarChooser: EKCalendarChooser = {
        var chooser = EKCalendarChooser(selectionStyle: .single, displayStyle: .writableCalendarsOnly, entityType: .event, eventStore: CoursesExportManager.shared.eventStore)
        chooser.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addCalendar(_:)))
        return chooser
    }()
    
    var coursesExportManager = CoursesExportManager.shared

    @IBOutlet weak var selectCalendarCell: UITableViewCell!
    @IBOutlet weak var chosenCalendarTitleLabel: UILabel!
    @IBOutlet weak var exportCell: UITableViewCell!
    @IBOutlet weak var deleteAllCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coursesExportManager.authorize { (success, error) in
            if success {
                // maybe nothing need to be done?
            } else {
                // Alert fail
                // Navigate user to settings
            }
        }
    }
    
    // MARK: Actions
    func addCalendar(_ sender: UIBarButtonItem) {
        if let createNewCalendarViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreateNewCalendarVC") {
            self.present(createNewCalendarViewController, animated: true) {
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            
            if cell === selectCalendarCell {
                calendarChooser.delegate = self
                self.navigationController?.pushViewController(calendarChooser, animated: true)
            }
            
            if cell === exportCell {
                coursesExportManager.export(completion: { (success, message) in
                    if success {
                        // Alert success
                        dismiss(animated: true, completion: nil)
                    } else {
                        // Alert fail
                    }
                })
            }
            
            if cell === deleteAllCell {
                coursesExportManager.deleteAll(completion: { (success, message) in
                    if success {
                        // Alert success
                    }
                })
            }
            
            cell.setSelected(false, animated: true)
        }
    
    }
    
    // MARK: - Calendar Chooser delegate
    func calendarChooserSelectionDidChange(_ calendarChooser: EKCalendarChooser) {
        if let chosenCalendar = calendarChooser.selectedCalendars.first {
            coursesExportManager.chosenCalendar = chosenCalendar
            chosenCalendarTitleLabel.text = chosenCalendar.title
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
