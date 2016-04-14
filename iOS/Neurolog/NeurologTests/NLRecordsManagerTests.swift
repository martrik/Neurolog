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
    let visitsManager = NLVisitsManager.sharedInstance
    
    override func setUp() {
        super.setUp()
    }
    
    func generateRecordInfo(teaching: Bool) -> [String: Any?] {
        var info : [String: Any?] = [
            "date" : Randoms.randomDateWithinDaysBeforeToday(5),
            "location" : Randoms.randomFakeCity(),
            "supervisorname" : Randoms.randomFakeName()
        ]
        
        if teaching {
            info["setting"] = "Teaching"
            info["teachingtitle"] = Randoms.randomFakeTitle()
            info["teachingtopic"] = NLSelectionManager.sharedInstance.portfolioTopics()[Randoms.randomInt(0,30)]
            info["teachinglecturer"] = Randoms.randomFakeName()
        } else {
            info["setting"] = NLSelectionManager.sharedInstance.clinicalSettings().filter(){$0 != "Teaching"}.randomItem()
        }

        return info
    }
    
    
    func testSaveClinicRecord() {
        let info = generateRecordInfo(false)
        let savedRecord = manager.saveRecordWith(info)
        
        XCTAssertEqualWithAccuracy(savedRecord.date.timeIntervalSinceReferenceDate, (info["date"] as? NSDate)!.timeIntervalSinceReferenceDate, accuracy: 1)
        XCTAssertEqual(savedRecord.location, info["location"] as? String)
        XCTAssertEqual(savedRecord.setting, info["setting"] as? String)
        XCTAssertEqual(savedRecord.supervisor, info["supervisorname"] as? String)
        
        XCTAssertNil(savedRecord.teachingInfo)
        
        XCTAssertEqual(savedRecord.visits.count, 0)
    }
    
    
    func testSaveTeachingRecord() {
        let info = generateRecordInfo(true)
        let savedRecord = manager.saveRecordWith(info)
        
        XCTAssertEqualWithAccuracy(savedRecord.date.timeIntervalSinceReferenceDate, (info["date"] as? NSDate)!.timeIntervalSinceReferenceDate, accuracy: 1)
        XCTAssertEqual(savedRecord.location, info["location"] as? String)
        XCTAssertEqual(savedRecord.setting, info["setting"] as? String)
        XCTAssertEqual(savedRecord.supervisor, info["supervisorname"] as? String)
        
        XCTAssertEqual(savedRecord.teachingInfo!.title, info["teachingtitle"] as? String)
        XCTAssertEqual(savedRecord.teachingInfo!.lecturer, info["teachinglecturer"] as? String)
        XCTAssertEqual(savedRecord.teachingInfo!.topic, info["teachingtopic"] as? String)
       
        XCTAssertEqual(savedRecord.visits.count, 0)
    }
    
    
    func testApproveRecord() {
        let savedRecord = manager.saveRecordWith(generateRecordInfo(false))
        let signaturePath = Randoms.randomNSURL().absoluteString
        manager.approveRecord(savedRecord, signaturePath: signaturePath)
        
        XCTAssertNotNil(savedRecord.signaturePath)
        XCTAssertEqual(savedRecord.signaturePath, signaturePath)       
    }
    
    
    func testDeleteRecord() {
        let savedRecord = manager.saveRecordWith(generateRecordInfo(false))
        let count = manager.allRecords().count
        
        manager.deleteRecord(savedRecord)
        
        XCTAssertEqual(manager.allRecords().count, count-1)        
    }

    
    func testEditClinicRecord() {
        let savedRecord = manager.saveRecordWith(generateRecordInfo(false))
        let newInfo = generateRecordInfo(false)
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
    
    
    func testEditTeachingRecord() {
        let savedRecord = manager.saveRecordWith(generateRecordInfo(true))
        let newInfo = generateRecordInfo(true)
        manager.updateRecord(savedRecord, info: newInfo)
        
        XCTAssertEqualWithAccuracy(savedRecord.date.timeIntervalSinceReferenceDate, (newInfo["date"] as? NSDate)!.timeIntervalSinceReferenceDate, accuracy: 1)
        XCTAssertEqual(savedRecord.location, newInfo["location"] as? String)
        XCTAssertEqual(savedRecord.setting, newInfo["setting"] as? String)
        XCTAssertEqual(savedRecord.supervisor, newInfo["supervisorname"] as? String)
        
        XCTAssertNotNil(savedRecord.teachingInfo)
        XCTAssertEqual(savedRecord.teachingInfo!.title, newInfo["teachingtitle"] as? String)
        XCTAssertEqual(savedRecord.teachingInfo!.lecturer, newInfo["teachinglecturer"] as? String)
        XCTAssertEqual(savedRecord.teachingInfo!.topic, newInfo["teachingtopic"] as? String)
        
        XCTAssertEqual(savedRecord.visits.count, 0)
    }
    
    
    func testAllRecords() {
        if manager.allRecords().count > 0 {
            XCTAssertNotNil(manager.allRecords())
        }
    }

}
