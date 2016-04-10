//
//  NLRecordsManagerTests.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 10/04/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import XCTest
import SwiftRandom

@testable import Neurolog

class NLRecordsManagerTests: XCTestCase {
    let manager = NLRecordsManager.sharedInstance

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func generateRecordInfo() -> [String: Any?] {
        var info : [String: Any?] = [
            "date" : Randoms.randomDateWithinDaysBeforeToday(5),
            "location" : Randoms.randomFakeCity(),
            "setting" : NLSelectionManager.sharedInstance.clinicalSettings()[Randoms.randomInt(0,4)],
            "supervisorname" : Randoms.randomFakeName()
        ]
        
        if info["setting"] as! String == "Teaching" {
            info["teachingtitle"] = Randoms.randomFakeTitle()
            info["teachingtopic"] = NLSelectionManager.sharedInstance.portfolioTopics()[Randoms.randomInt(0,30)]
            info["teachinglecturer"] = Randoms.randomFakeName()
        }

        return info
    }
    
    
    func testSaveRecord() {
        let info = generateRecordInfo()
        let savedRecord = manager.saveRecordWith(info)
        
        XCTAssertEqualWithAccuracy(savedRecord.date.timeIntervalSinceReferenceDate, (info["date"] as? NSDate)!.timeIntervalSinceReferenceDate, accuracy: 1)
        XCTAssertEqual(savedRecord.location, info["location"] as? String)
        XCTAssertEqual(savedRecord.setting, info["setting"] as? String)
        XCTAssertEqual(savedRecord.supervisor, info["supervisorname"] as? String)
        
        if savedRecord.setting == "Teaching" {
            XCTAssertNotNil(savedRecord.teachingInfo)
            XCTAssertEqual(savedRecord.teachingInfo!.title, info["teachingtitle"] as? String)
            XCTAssertEqual(savedRecord.teachingInfo!.lecturer, info["teachinglecturer"] as? String)
            XCTAssertEqual(savedRecord.teachingInfo!.topic, info["teachingtopic"] as? String)
        } else {
            XCTAssertNil(savedRecord.teachingInfo)
        }
        
        XCTAssertEqual(savedRecord.visits.count, 0)
    }
    
    
    func testApproveRecord() {
        let savedRecord = manager.saveRecordWith(generateRecordInfo())
        let signaturePath = Randoms.randomNSURL().absoluteString
        manager.approveRecord(savedRecord, signaturePath: signaturePath)
        
        XCTAssertNotNil(savedRecord.signaturePath)
        XCTAssertEqual(savedRecord.signaturePath, signaturePath)       
    }
    
    
    func testSaveVisitInRecord() {
        let savedRecord = manager.saveRecordWith(generateRecordInfo())
        
        let info: [String: Any?] = [
            "disease" : NLSelectionManager.sharedInstance.portfolioTopics()[Randoms.randomInt(0,30)],
            "age" : String(Randoms.randomInt(0, 120)),
            "sex" : Randoms.randomFakeGender()
        ]
        
        let visit = manager.saveVisitInRecord(savedRecord, info: info)!
        
        XCTAssertEqual(visit.topic, info["disease"] as? String)
        XCTAssertEqual(String(visit.age), info["age"] as? String)
        XCTAssertEqual(visit.sex, info["sex"] as? String)
        
        XCTAssertEqual(savedRecord.visits.count, 1)
    }

    
    func testUpdatedRecord() {
        let savedRecord = manager.saveRecordWith(generateRecordInfo())
        let newInfo = generateRecordInfo()
        manager.updateRecord(savedRecord, info: newInfo)

        XCTAssertEqualWithAccuracy(savedRecord.date.timeIntervalSinceReferenceDate, (newInfo["date"] as? NSDate)!.timeIntervalSinceReferenceDate, accuracy: 1)
        XCTAssertEqual(savedRecord.location, newInfo["location"] as? String)
        XCTAssertEqual(savedRecord.setting, newInfo["setting"] as? String)
        XCTAssertEqual(savedRecord.supervisor, newInfo["supervisorname"] as? String)

        if savedRecord.setting == "Teaching" {
            XCTAssertNotNil(savedRecord.teachingInfo)
            XCTAssertEqual(savedRecord.teachingInfo!.title, newInfo["teachingtitle"] as? String)
            XCTAssertEqual(savedRecord.teachingInfo!.lecturer, newInfo["teachinglecturer"] as? String)
            XCTAssertEqual(savedRecord.teachingInfo!.topic, newInfo["teachingtopic"] as? String)
        } else {
            XCTAssertNil(savedRecord.teachingInfo?.lecturer)
            XCTAssertNil(savedRecord.teachingInfo?.topic)
            XCTAssertNil(savedRecord.teachingInfo?.title)
        }

        XCTAssertEqual(savedRecord.visits.count, 0)
    }
    
    
    func testAllRecords() {
        let initial = manager.allRecords().count
        let count = Randoms.randomInt(1, 10)
        
        for _ in [ 1...count] {
            manager.saveRecordWith(generateRecordInfo())
        }
        
        XCTAssertEqual(manager.allRecords().count, initial + count)
    }

}
