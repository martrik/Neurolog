//
//  NLVisitsManagerTests.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 13/04/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import XCTest
import RealmSwift
import SwiftRandom

@testable import Neurolog

class NLVisitsManagerTests: XCTestCase {
    let manager = NLVisitsManager.sharedInstance

    override func setUp() {
        super.setUp()
    }
    
    
    func infoForVisit() -> ([String: Any?]) {
        let info: [String: Any?] = [
            "disease" : NLSelectionManager.sharedInstance.portfolioTopics()[Randoms.randomInt(0,30)],
            "age" : String(Randoms.randomInt(0, 120)),
            "sex" : Randoms.randomFakeGender()
        ]
        
        return info
    }
    
    
    func testSaveVisitInRecord() {
        let savedRecord = NLRecordsManager.sharedInstance.allRecords().randomItem()
        let initial = savedRecord.visits.count
        
        let info = infoForVisit()
        
        let visit = manager.saveVisitInRecord(savedRecord, info: info)!
        
        XCTAssertEqual(visit.topic, info["disease"] as? String)
        XCTAssertEqual(String(visit.age), info["age"] as? String)
        XCTAssertEqual(visit.sex, info["sex"] as? String)
        
        XCTAssertEqual(savedRecord.visits.count, initial + 1)
    }
    
    
    func testDeleteVisis() {
        let realm = try! Realm()
        
        let visit: Visit?
        if Array(realm.objects(Visit)).count > 0 {
            visit = Array(realm.objects(Visit)).randomItem()
        } else {
            let savedRecord = NLRecordsManager.sharedInstance.allRecords().randomItem()
            visit = manager.saveVisitInRecord(savedRecord, info: infoForVisit())!
        }
        
        let record = visit!.record!
        let count = record.visits.count
        
        manager.deleteVisitFromRecord(visit!, record: record)
        
        XCTAssertEqual(record.visits.count, count-1)
    }

}
