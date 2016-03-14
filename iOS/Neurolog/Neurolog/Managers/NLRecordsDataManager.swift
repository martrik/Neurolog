//
//  RecordsDataManager.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 13/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit
import RealmSwift

class Record: Object {
    dynamic var date = ""
    dynamic var time = ""
    dynamic var facility = ""
    dynamic var portfolio = ""
    dynamic var disease = ""
    dynamic var signed = false
    dynamic var supervisor: String? = nil
    
}

class NLRecordsDataManager: NSObject {
    static let sharedInstance = NLRecordsDataManager()
    
    func saveRecordWith(info: [String], signed: Bool, supervisor: String?) {
        let realm = try! Realm()
        
        let newRecord = Record()
        newRecord.date = info[0]
        newRecord.time = info[1]
        newRecord.facility = info[2]
        newRecord.portfolio = info[3]
        newRecord.disease = info[4]
        newRecord.signed = signed
        
        if (signed) {
            newRecord.supervisor = supervisor!
        }
        
        try! realm.write {
            realm.add(newRecord)
        }
    }
    
    func updateRecord(record: Record, info: [String], signed: Bool, supervisor: String?) {
        let realm = try! Realm()
        
        try! realm.write {
            record.date = info[0]
            record.time = info[1]
            record.facility = info[2]
            record.portfolio = info[3]
            record.disease = info[4]
            record.signed = signed
            record.supervisor = supervisor
        }
    }
    
    func getAllRecords() -> ([Record]) {
        let realm = try! Realm()
        let allRecords = realm.objects(Record)
        
        return Array(allRecords)
    }
    
    func getRecordsWithFacility(facility: String) -> ([Record]) {
        let realm = try! Realm()
        let facilityRecords = realm.objects(Record).filter("facility = '\(facility)'")
        
        return Array(facilityRecords)
    }
    
    func getRecordsWithDisease(disease: String) -> ([Record]) {
        let realm = try! Realm()
        let facilityRecords = realm.objects(Record).filter("disease = \(disease)")
        
        return Array(facilityRecords)
    }

}
