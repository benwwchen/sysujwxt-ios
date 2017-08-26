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
    var day: Int
    
    var dayString: String? {
        get {
            return DayOfWeek.fromNumber(number: day)?.description
        }
    }
    
    var duration: String
    
    // the 2 properties below are in units of classes
    var startClass: Int
    var endClass: Int
    
    // return real class start and end time (get only)
    var startTime: (Int, Int)? {
        get {
            return Course.ClassTime[startClass]
        }
    }
    
    var endTime: (Int, Int)? {
        get {
            return Course.ClassTime[endClass]
        }
    }
    
    // MARK: Constants
    // maps class index to real start time (45 minutes long each class)
    static let ClassTime: [Int: (Int, Int)] = {
        
        var classTimeDict = [Int: (Int, Int)]()
        classTimeDict[1] = (8,00)
        classTimeDict[2] = (8,55)
        classTimeDict[3] = (10,00)
        classTimeDict[4] = (10,55)
        classTimeDict[5] = (14,20)
        classTimeDict[6] = (15,15)
        classTimeDict[7] = (16,20)
        classTimeDict[8] = (17,15)
        classTimeDict[9] = (19,00)
        classTimeDict[10] = (19,55)
        classTimeDict[11] = (20,50)
        
        return classTimeDict
        
    }()
    
    // class timetable before 2017-2018 school year
    static let oldClassTime: [Int: (Int, Int)] = {
        
        var classTimeDict = [Int: (Int, Int)]()
        classTimeDict[1] = (8,00)
        classTimeDict[2] = (8,55)
        classTimeDict[3] = (9,50)
        classTimeDict[4] = (10,45)
        classTimeDict[5] = (11,40)
        classTimeDict[6] = (12,35)
        classTimeDict[7] = (13,30)
        classTimeDict[8] = (14,25)
        classTimeDict[9] = (15,20)
        classTimeDict[10] = (16,15)
        classTimeDict[11] = (17,10)
        classTimeDict[12] = (18,05)
        classTimeDict[13] = (19,00)
        classTimeDict[14] = (19,55)
        classTimeDict[15] = (20,50)
        
        return classTimeDict
        
    }()
    
    //MARK: Initialization
    
    init(name: String, location: String, day: Int, startClass: Int, endClass: Int, duration: String) {
        self.name = name
        self.location = location
        self.day = day
        self.startClass = startClass
        self.endClass = endClass
        self.duration = duration
    }
    
}
