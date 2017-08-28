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
    var identifiers: [String] = UserDefaults.standard.object(forKey: "Courses.Events.Identifiers") as? [String] ?? [String]() {
        willSet {
            UserDefaults.standard.set(newValue, forKey: "Courses.Events.Identifiers")
        }
    }
    var isAuthorized: Bool = false
    
    // MARK: Constants
    
    // maps year, term to opening day
    let OpeningDay: [Int: [Int: (Int, Int, Int)]] = {
        
        // TODO: retrieve this from the server instead of hard-coded
        
        var openingDayDict = [Int: [Int: (Int, Int, Int)]]()
        
        openingDayDict[2017] = [Int: (Int, Int, Int)]()
        openingDayDict[2018] = [Int: (Int, Int, Int)]()
        
        openingDayDict[2017]?[1] = (2017,9,3)
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
    
    func authorize(completion: @escaping (_ success: Bool, _ object: Any?) -> ()) {
        let eventStatus = EKEventStore.authorizationStatus(for: .event)
        if eventStatus == .notDetermined {
            eventStore.requestAccess(to: .event) { (success, error) in
                if success {
                    self.isAuthorized = true
                }
                completion(success, error)
            }
        } else if eventStatus == .denied {
            completion(false, nil)
        } else if eventStatus == .authorized {
            self.isAuthorized = true
            completion(true, nil)
        } else {
            // restricted
            completion(false, nil)
        }
    }
    
    func chooseCalendar() {
        
    }
    
    func export(year: Int, term: Int) {
        if isAuthorized {
            // try to export courses to the user's system calendar
            for course in self.courses {
                
                let cleanDuration = String(course.duration.characters.filter({ "0123456789.-".characters.contains($0) }))
                
                guard let startWeek = Int(cleanDuration.components(separatedBy: "-")[0]),
                    let endWeek = Int(cleanDuration.components(separatedBy: "-")[1]),
                    let weekDay = course.day.ekDayOfWeek else {
                    return
                }
                
                let recurrenceRule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.weekly, interval: 1, daysOfTheWeek: [EKRecurrenceDayOfWeek(weekDay)], daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: EKRecurrenceEnd(occurrenceCount: endWeek - startWeek + 1))
                
                guard let startYear = self.OpeningDay[year]?[term]?.0,
                    let startMonth = self.OpeningDay[year]?[term]?.1,
                    let startDay = self.OpeningDay[year]?[term]?.2,
                    let startHour = course.startTime?.0,
                    let startMinute = course.startTime?.1,
                    let openningDate = Date(year: startYear, month: startMonth, day: startDay),
                    let startDate = openningDate.startOfWeek?.shift(week: startWeek - 1, day: course.day.dayNumber, hour: startHour, minute: startMinute),
                    let endHour = course.endTime?.0,
                    let endMinute = course.endTime?.1 else {
                    return
                }
                
                // all info got, create a recurring event now
                let event = EKEvent(eventStore: self.eventStore)
                event.calendar = self.eventStore.defaultCalendarForNewEvents
                event.title = course.name
                event.location = course.location
                
                var firstClassDate = startDate
                if firstClassDate < openningDate {
                    // not taking class at week 1
                    firstClassDate = firstClassDate.shift(week: 1)!
                    recurrenceRule.recurrenceEnd = EKRecurrenceEnd(occurrenceCount: endWeek - startWeek)
                }
                
                event.startDate = firstClassDate
                
                // get the components of startDate and add the end hour and minute to it
                var components = Calendar.current.dateComponents([.year, .month, .day], from: firstClassDate)
                components.hour = endHour
                components.minute = endMinute
                event.endDate = Calendar.current.date(from: components)!
                
                event.addRecurrenceRule(recurrenceRule)
                
                // try to add it to the calendar
                do {
                    try self.eventStore.save(event, span: .futureEvents)
                    
                    // save its identifier for future deletion
                    self.identifiers.append(event.eventIdentifier)
                } catch {
                    print(error)
                }
                
            }
        } else {
            // no permission
            
        }
    }
    
    func deleteAll() {
        for identifier in identifiers {
            print(identifier)
            if let event = eventStore.event(withIdentifier: identifier) {
                do {
                    try eventStore.remove(event, span: .futureEvents)
                } catch {
                    print(error)
                }
            }
        }
    }
}

extension Date {
    
    var startOfWeek: Date? {
        return Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
    
    func shift(week: Int = 0, day: Int = 0, hour: Int = 0, minute: Int = 0) -> Date? {
        var components = DateComponents()
        components.day = 7 * week + day
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(byAdding: components, to: self)
    }
    
    init?(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0) {
        
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.timeZone = TimeZone(abbreviation: "CT") // China Time
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        if let date = Calendar.current.date(from: dateComponents) {
            self = date
        } else {
            return nil
        }
    }
}
