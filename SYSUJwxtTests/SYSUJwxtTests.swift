//
//  SYSUJwxtTests.swift
//  SYSUJwxtTests
//
//  Created by benwwchen on 2017/8/17.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import XCTest
@testable import SYSUJwxt

class SYSUJwxtTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    //MARK: Course Class Tests
    // Confirm that the Course initializer returns a Course object when passed valid parameters.
    func testCourseInitializationSucceeds() {
        
        //let zeroRatingMeal = Meal.init(name: "Zero", photo: nil, rating: 0)
        //XCTAssertNotNil(zeroRatingMeal)
        
        // Highest positive rating
        //let positiveRatingMeal = Meal.init(name: "Positive", photo: nil, rating: 5)
        //XCTAssertNotNil(positiveRatingMeal)
    }
    
    //MARK: Test Sync Network
    func testSync() {
        let request = URLRequest(url: URL(string: "https://www.baidu.com/")!)
        let (data, _) = try! URLSession.shared.synchronousDataTask(with: request)
        print ("\(String(describing: NSString(data: data!, encoding: String.Encoding.utf8.rawValue)))")
    }
    
    //MARK: Test Jwxt API
    func testJwxtApis() {
        
        let expect = expectation(description: "result")
        
        if let jwxt = JwxtApiClient(netId: "chenww28", password: "ja6one?T") {
            jwxt.login(completion: { (success, message) in
                
                if success {
                    print("student no: \(jwxt.studentNumber)")
                    print("grade: \(jwxt.grade)")
                    print("school ID: \(jwxt.schoolId)")
                }
                
                print ("\(String(describing: message))")
                
                jwxt.getCourseList(year: 2016, term: 1, completion: { (success, result) in
                    print("courses: \(result)")
                    jwxt.getScoreList(year: 2015, term: 1, completion: { (success, result) in
                        print("scores: \(result)")
                        jwxt.getGPA(year: 2015, term: 1, completion: { (success, result) in
                            print("courses: \(result)")
                            expect.fulfill()
                        })
                    })
                })
                
            })
        }
        
        waitForExpectations(timeout: 100, handler: nil)
        
    }
}
