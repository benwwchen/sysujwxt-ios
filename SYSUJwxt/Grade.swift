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
    
}
