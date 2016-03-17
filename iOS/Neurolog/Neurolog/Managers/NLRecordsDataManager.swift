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
    dynamic var date = NSDate()
    dynamic var location = ""
    dynamic var facility = ""
    dynamic var supervisor: String? = nil
    let visits = List<Visit>()
    
}

class Visit: Object {
    dynamic var time = NSDate()
    dynamic var topic = ""
    dynamic var sex = ""
    dynamic var age = 1
}

class NLRecordsDataManager: NSObject {
    static let sharedInstance = NLRecordsDataManager()
    
    // MARK: Records
    
    func saveRecordWith(info: [String : Any?]) -> (Record) {
        let realm = try! Realm()
        
        let newRecord = Record()
        
        if let date = info["date"] {
            newRecord.date = date as! NSDate
        }
        if let location = info["location"] {
            newRecord.location = location as! String
        }
        if let facility = info["facility"] {
            newRecord.facility = facility as! String
        }
        if let supervisor = info["supervisor"] {
            newRecord.supervisor = supervisor as? String
        }
        
        try! realm.write {
            realm.add(newRecord)
        }
        
        return newRecord
    }
    
    func updateRecord(record: Record, info: [String : Any?]) {
        let realm = try! Realm()
        
        try! realm.write {
            if let date = info["date"] {
                record.date = date as! NSDate
            }
            if let location = info["location"] {
                record.location = location as! String
            }
            if let facility = info["facility"] {
                record.facility = facility as! String
            }
            if let supervisor = info["supervisor"] {
                record.supervisor = supervisor as? String
            }
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
    
    func getRecordsWithSupervisor(disease: String) -> ([Record]) {
        let realm = try! Realm()
        let supervisorRecords = realm.objects(Record).filter("supervisor = \(disease)")
        
        return Array(supervisorRecords)
    }
    
    // MARK: - Visits
    
    func saveVisitInRecord(record: Record, info: [String: Any?]) {
        let realm = try! Realm()
        
        let newVisit = Visit()

        if let time = info["time"] {
            newVisit.time = time as! NSDate
        }
        if let disease = info["disease"] {
            newVisit.topic = disease as! String
        }
        if let age = info["age"] {
            newVisit.age = Int(age as! String)!
        }
        if let sex = info["sex"] {
            newVisit.sex = sex as! String!
        }
        
        try! realm.write {
           record.visits.append(newVisit)
        }
    }
    
    /*func getStatsForDisease() -> (Dictionary<String, Int>) {
        let realm = try! Realm()
        let 
        
    }*/

}
