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
    var chosenCalendar: EKCalendar? = nil
    var year = 0
    var term = 0
    
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
    
    struct Messages {
        static let NotSupported = "暂不支持2017学年前课程表"
        static let NoChosenCalendar = "还未选择要导出到的日历😅"
        static let BadData = "课程数据有问题，导出不了😅"
        static let CommitError = "无法提交修改，请检查是否已打开日历权限😅"
        static let ExportSuccess = "导出完成"
        static let ExportFail = "导出失败"
        static let DeleteSuccess = "已删除"
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
    
    func getCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }
    
    func export(completion: (Bool, (String, String)) -> Void) {
        
        if year < 2017 {
            // not supported yet
            completion(false, (Messages.ExportFail, Messages.NotSupported))
        }
        
        for course in self.courses {
                
            let cleanDuration = String(course.duration.characters.filter({ "0123456789.-".characters.contains($0) }))
            
            guard let startWeek = Int(cleanDuration.components(separatedBy: "-")[0]),
                let endWeek = Int(cleanDuration.components(separatedBy: "-")[1]),
                let weekDay = course.day.ekDayOfWeek else {
                completion(false, (Messages.ExportFail, Messages.BadData))
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
                completion(false, (Messages.ExportFail, Messages.BadData))
                return
            }
            
            // all info got, create a recurring event now
            let event = EKEvent(eventStore: self.eventStore)
            
            if let chosenCalendar = chosenCalendar {
                event.calendar = chosenCalendar
            } else {
                completion(false, (Messages.ExportFail, Messages.NoChosenCalendar))
                return
            }
            
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
                
                // roll back
                deleteAll(completion: nil)
                completion(false, (Messages.ExportFail, Messages.CommitError))
            }
            
        }
        
        completion(true, (Messages.ExportSuccess, "已导出\(courses.count)门课程到系统日历"))
    }
    
    func deleteAll(completion: ((Bool, (String, String)) -> Void)? = nil) {
        for identifier in identifiers {
            print(identifier)
            if let event = eventStore.event(withIdentifier: identifier) {
                do {
                    try eventStore.remove(event, span: .futureEvents)
                } catch {
                    print(error)
                    //completion(false, Messages.DeleteFail)
                }
            }
        }
        let count = identifiers.count
        identifiers.removeAll()
        completion?(true, (Messages.DeleteSuccess, "已从系统日历中移除\(count)门课程"))
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
