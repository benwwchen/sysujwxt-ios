//
//  DayOfWeek.swift
//  SYSUJwxt
//
//  Originally Created by Guido Marucci Blas on 9/13/14.
//  Translated into Chinese by benwwchen on 2017/8/21.
//

import Foundation
import EventKit

enum DayOfWeek: String {
    case Monday = "星期一"
    case Tuesday = "星期二"
    case Wednesday = "星期三"
    case Thursday = "星期四"
    case Friday = "星期五"
    case Saturday = "星期六"
    case Sunday = "星期日"
    
    var description: String {
        get {
            return self.rawValue
        }
    }
    
    var dayNumber: Int {
        get {
            return self.hashValue + 1
        }
    }
    
    var ekDayOfWeek: EKWeekday? {
        get {
            return EKWeekday(rawValue: (self.dayNumber + 1) % 7)
        }
    }
    
    private static let days = [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
    
    static func fromNumber(number: Int) -> DayOfWeek? {
        guard number >= 1 && number <= 7 else {
            return nil
        }
        
        return days[number-1]
    }
}
