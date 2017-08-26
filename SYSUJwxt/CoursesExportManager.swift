//
//  CoursesExportManager.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/26.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import Foundation
import EventKit

class CoursesExportManager {
    
    // MARK: Properties
    lazy var eventStore = EKEventStore()
    var courses: [Course]
    
    // MARK: Constants
    
    // maps year, term to opening day
    static let OpeningDay: [Int: [Int: (Int, Int, Int)]] = {
        
        var openingDayDict = [Int: [Int: (Int, Int, Int)]]()
        
        openingDayDict[2017]?[1] = (2017,9,2)
        openingDayDict[2017]?[2] = (2018,3,4)
        openingDayDict[2018]?[1] = (2018,9,2)
        
        return openingDayDict
        
    }()
    
    enum CourseExportError: Error {
        case badData
    }
    
    // MARK: Initialization
    
    private init() {
        self.courses = [Course]()
    }
    
    // MARK: Shared Instance
    
    static let shared = CoursesExportManager()
    
    func export(year: Int, term: Int) {
        eventStore.requestAccess(to: .event) { (success, error) in
            if success {
                // try to export courses to the user's system calendar
                for course in self.courses {
                    let event = EKEvent(eventStore: self.eventStore)
                    event.title = course.name
                    event.location = course.location
                    
                    guard let startWeek = Int(course.duration.components(separatedBy: "-")[0]), let endWeek = Int(course.duration.components(separatedBy: "-")[1]) else {
                        return
                    }
                    
                    var recurrenceRule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.weekly, interval: 1, end: EKRecurrenceEnd(occurrenceCount: endWeek - startWeek + 1))
                    
                    guard let startYear = CoursesExportManager.OpeningDay[year]?[term]?.0,
                        let startMonth = CoursesExportManager.OpeningDay[year]?[term]?.1,
                        let startDay = CoursesExportManager.OpeningDay[year]?[term]?.2,
                        let startHour = course.startTime?.0,
                        let startMinute = course.startTime?.1,
                        let startDate = Date(year: startYear, month: startMonth, day: startDay, hour: startHour, minute: startMinute) else {
                        return
                    }
                    
                    
                    
                    
                    // TODO: create recurring events for each event
                    
                }
                
            } else {
                // user denied permission
                
            }
        }
    }
    
}

extension Date {
    init?(year: Int, month: Int, day: Int, hour: Int, minute: Int) {
        
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.timeZone = TimeZone(abbreviation: "JST") // Japan Standard Time
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        if let date = Calendar.current.date(from: dateComponents) {
            self = date
        } else {
            return nil
        }
    }
}
