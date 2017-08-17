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
    
    // the 3 properties below are in units of classes
    var startTime: Int
    var endTime: Int
    var duration: Int
    
    
    //MARK: Initialization
    
    init(name: String, location: String, day: Int, startTime: Int, endTime: Int, duration: Int) {
        self.name = name
        self.location = location
        self.day = day
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
    }
    
}
