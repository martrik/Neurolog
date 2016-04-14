//
//  NLStatsManagerTests.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 11/04/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Neurolog

class NLStatsManagerTests: XCTestCase {
    let manager = NLStatsManager.sharedInstance
    let recordsManager = NLRecordsManager.sharedInstance
    let realm = try! Realm()

    override func setUp() {
        super.setUp()
    }
    
    
    func testRecordsBySettingHasAllRecords() {
        let stats = manager.statsForClinicalSettings()
        var count = 0
        
        for num in stats.1 {
            count += num
        }
        
        let realm = try! Realm()
        
        XCTAssertEqual(count, realm.objects(Record).count)
    }
    

    func testVisitsByAgeHasAllVisits() {
        let stats = manager.statsForAgeRanges()
        var count = 0
        
        for num in stats.1 {
            count += num
        }
        
        XCTAssertEqual(count, realm.objects(Visit).count)
    }
    
    
    func testStatsForTopic() {
        let realm = try! Realm()
        
        let stats = manager.statsForTopics(NSDate(timeIntervalSince1970: 1), to: NSDate())
        var count = 0
        
        for num in stats.1 {
            count += num
        }
            
        XCTAssertEqual(count, realm.objects(Visit).count)
    }
    

    func testsStatsForTeaching() {        
        let stats = manager.statsForTeaching(NSDate(timeIntervalSince1970: 1), to: NSDate())
        var count = 0
        
        
        for (_, num) in stats {
            count += num
        }
        
        XCTAssertEqual(count, realm.objects(Record).filter("setting = 'Teaching'").count)
    }

}
