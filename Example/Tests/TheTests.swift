//
//  TheTests.swift
//  Hellfire_Tests
//
//  Created by Ed Hellyer on 9/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest

class TheTests: XCTestCase {
    
    //private let hasher = MD5Hash()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHasher() {

//        var bigDic = Dictionary<String, String>()
//
//        for _ in 1...10000 {
//            let strLength = Int(arc4random_uniform(21) + 50)
//            let seedStr = String.randomString(length: strLength)
//            bigDic[seedStr] = self.hasher.MD5(seedStr)
//        }
//
//        //Test repeatable hash values
//        for key in bigDic.keys {
//            let value = bigDic[key]
//            let compartStr = self.hasher.MD5(key)
//            print("\(value!)  ==  \(compartStr)        Key: \(key)")
//            XCTAssert(value == compartStr)
//        }
//
//        //Test for uniqueness
//        let set = Set<String>(bigDic.values)
//
//        print(set.count)
//        print(bigDic.count)
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    //Mark: - Service Tests
    func testPerson() {
        let jsonStr = """
        {
        "first_Name": "Edward",
        "last_Name": "Hellyer",
        "a_fantastic_person": true
        }
        """
        let jsonData = Data(jsonStr.utf8)
        if let person = Person.initialize(jsonData: jsonData) {
            print(person.firstName)
            print(person.lastName)
            print("Is this person awesome? \(person.isAwesome ? "Yes" : "Not so much")")
            if let personJSONStr = person.toJSONString() {
                print(personJSONStr as NSString)
            }
        }
        
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }
    
    func testBirthday1() {
        let jsonStr = """
        {
        "birthdate": "1975-03-21"
        }
        """
        self.printBirthdate(jsonStr: jsonStr)
    }

    func testBirthday2() {
        let jsonStr = """
        {
        "birthdate": "2004-03-09"
        }
        """
        self.printBirthdate(jsonStr: jsonStr)
    }
    
    private func printBirthdate(jsonStr: String) {
        let jsonData = Data(jsonStr.utf8)
        if let bday = Birthday.initialize(jsonData: jsonData) {
            print(bday.birthdate)
        }
    }
}
