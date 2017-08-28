//
//  Course.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/17.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import Foundation

class Course {
    
    //MARK: Properties
    
    var name: String
    var location: String
    var day: DayOfWeek
    
    var duration: String
    
    // the 2 properties below are in units of classes
    var startClass: Int
    var endClass: Int
    
    // return real class start and end time (get only)
    var startTime: (Int, Int)? {
        get {
            return Course.ClassTime.TimeTable[startClass]
        }
    }
    
    var endTime: (Int, Int)? {
        get {
            if let startTime = ClassTime.TimeTable[endClass] {
                let minute = (startTime.1 + ClassTime.Duration) % 60
                let hour = startTime.1 + ClassTime.Duration >= 60 ? startTime.0 + 1 : startTime.0
                return (hour, minute)
            }
            
            return nil
        }
    }
    
    // MARK: Constants
    
    struct ClassTime {
        static let Duration = 45
        
        // maps class index to real start time
        static let TimeTable: [Int: (Int, Int)] = {
            
            var TimeTable = [Int: (Int, Int)]()
            TimeTable[1] = (8,00)
            TimeTable[2] = (8,55)
            TimeTable[3] = (10,00)
            TimeTable[4] = (10,55)
            TimeTable[5] = (14,20)
            TimeTable[6] = (15,15)
            TimeTable[7] = (16,20)
            TimeTable[8] = (17,15)
            TimeTable[9] = (19,00)
            TimeTable[10] = (19,55)
            TimeTable[11] = (20,50)
            
            return TimeTable
            
        }()
        
        // class timetable before 2017-2018 school year
        static let OldTimeTable: [Int: (Int, Int)] = {
            
            var TimeTable = [Int: (Int, Int)]()
            TimeTable[1] = (8,00)
            TimeTable[2] = (8,55)
            TimeTable[3] = (9,50)
            TimeTable[4] = (10,45)
            TimeTable[5] = (11,40)
            TimeTable[6] = (12,35)
            TimeTable[7] = (13,30)
            TimeTable[8] = (14,25)
            TimeTable[9] = (15,20)
            TimeTable[10] = (16,15)
            TimeTable[11] = (17,10)
            TimeTable[12] = (18,05)
            TimeTable[13] = (19,00)
            TimeTable[14] = (19,55)
            TimeTable[15] = (20,50)
            
            return TimeTable
            
        }()
    }
    
    
    
    
    //MARK: Initialization
    
    init?(name: String, location: String, day: Int, startClass: Int, endClass: Int, duration: String) {
        self.name = name
        self.location = location
        if let day = DayOfWeek.fromNumber(number: day) {
            self.day = day
        } else {
            return nil
        }
        self.startClass = startClass
        self.endClass = endClass
        self.duration = duration
    }
    
}
