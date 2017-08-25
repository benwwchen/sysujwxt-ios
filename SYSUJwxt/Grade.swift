//
//  Score.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/20.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import Foundation

enum CourseType: Int {
    case PublicCompulsory = 10
    case PublicElective = 30
    case MajorCompulsory = 11
    case MajorElective = 21
}

class Grade {
    
    //MARK: Properties
    
    var name: String
    var lecturer: String
    var totalGrade: Double
    var credit: Double
    var gpa: Double
    var period: Double
    var rankingInTeachingClass: String
    var rankingInMajorClass: String
    var courseType: CourseType
    
    //MARK: Initialization
    
    init?(json: [String: Any]) {
        guard let name = json["kcmc"] as? String,
            let lecturer = json["jsxm"] as? String,
            let totalGradeString = json["zpcj"] as? String,
            let totalGrade = Double(totalGradeString),
            let creditString = json["xf"] as? String,
            let credit = Double(creditString),
            let gpaString = json["jd"] as? String,
            let gpa = Double(gpaString),
            let periodString = json["xs"] as? String,
            let period = Double(periodString),
            let rankingInTeachingClass = json["jxbpm"] as? String,
            let rankingInMajorClass = json["njzypm"] as? String,
            let courseTypeString = json["kclb"] as? String,
            let courseTypeRaw = Int(courseTypeString),
            let courseType = CourseType(rawValue: courseTypeRaw)
            else {
                return nil
        }
        
        self.name = name
        self.lecturer = lecturer
        self.totalGrade = totalGrade
        self.credit = credit
        self.gpa = gpa
        self.period = period
        self.rankingInTeachingClass = rankingInTeachingClass
        self.rankingInMajorClass = rankingInMajorClass
        self.courseType = courseType
    }
    
    // only be used when restoring from dicts
    init(name: String, totalGrade: Double) {
        self.name = name
        self.totalGrade = totalGrade
        
        // the properties below will not be used
        self.lecturer = ""
        self.credit = 0
        self.gpa = 0
        self.period = 0
        self.rankingInTeachingClass = ""
        self.rankingInMajorClass = ""
        self.courseType = .MajorCompulsory
    }
    
    class func areEquals(grades1: [Grade], grades2: [Grade]) -> Bool {
        
        var array1 = grades1
        var array2 = grades2
        
        if array1.count != array2.count {
            return false
        }
        
        // sort two arrays
        array1.sort() { $0.name > $1.name }
        array2.sort() { $0.name > $1.name }
        
        // get count of the matched items
        let result = zip(array1, array2).enumerated().filter() {
            $1.0.name == $1.1.name && $1.0.totalGrade == $1.1.totalGrade
        }.count
        
        if result == array1.count {
            return true
        }
        
        return false
    }
    
    class func getDiff(oldGrades: [Grade], newGrades: [Grade]) -> [Grade] {
        
        var result = [Grade]()
        
        for newGrade in newGrades {
            if !oldGrades.contains(where: { return $0 == newGrade }) {
                result.append(newGrade)
            }
        }
        
        return result
        
    }
}

extension Grade {
    static func==(lhs: Grade, rhs: Grade) -> Bool {
        return lhs.name == rhs.name && lhs.totalGrade == rhs.totalGrade
    }
}
