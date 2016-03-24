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
    dynamic var setting = ""
    dynamic var supervisor: String? = nil
    dynamic var signaturePath: String? = nil
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
            newRecord.setting = facility as! String
        }
        if let supervisor = info["supervisorname"] {
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
                record.setting = facility as! String
            }
            if let supervisor = info["supervisorname"] {
                if supervisor as? String != record.supervisor {
                    record.signaturePath = nil
                }
                record.supervisor = supervisor as? String
            }
        }
    }
    
    func deleteVisitFromRecord(visit: Visit, record: Record) {
        let realm = try! Realm()
        
        try! realm.write {
            record.visits.removeAtIndex(record.visits.indexOf(visit)!)
        }
    }
    
    func approveRecord(record: Record, signaturePath: String) {
        let realm = try! Realm()
        
        try! realm.write {
            record.signaturePath = signaturePath
        }
    }
    
    func allRecords() -> ([Record]) {
        let realm = try! Realm()
        let allRecords = realm.objects(Record).sorted("date", ascending: false)
        
        return Array(allRecords)
    }
    
    func recordsWithFacility(facility: String) -> ([Record]) {
        let realm = try! Realm()
        let facilityRecords = realm.objects(Record).filter("facility = '\(facility)'")
        
        return Array(facilityRecords)
    }
    
    func recordsWithSupervisor(supervisor: String) -> ([Record]) {
        let realm = try! Realm()
        let supervisorRecords = realm.objects(Record).filter("supervisor = '\(supervisor)'")
        
        return Array(supervisorRecords)
    }
    
    // MARK: Visits
    
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
    
    // MARK: CSV generator
    
    func generateCSVWithRecords(records: [Record]) -> NSData {
        let mailString = NSMutableString()
        let timeFormatter = NSDateFormatter()
        timeFormatter.locale = NSLocale.currentLocale()
        
        for record in records {
            mailString.appendString("Date, Setting, Location, Supervisor\n")
            
            timeFormatter.dateStyle = .MediumStyle
            timeFormatter.timeStyle = .NoStyle
            let string = "\(timeFormatter.stringFromDate(record.date)), \(record.setting), \(record.location), " + (record.supervisor != nil ? record.supervisor!  : "none") + "\n"
            mailString.appendString(string)
            
            mailString.appendString("Time, Disease, Age, Sex\n")

            timeFormatter.dateStyle = .NoStyle
            timeFormatter.timeStyle = .ShortStyle
            
            for visit in record.visits {
                mailString.appendString("\(timeFormatter.stringFromDate(visit.time)), \(visit.topic), \(visit.age), \(visit.sex)\n")
            }
            
            mailString.appendString(" \n")
        }
        
        // Converting it to NSData.
        let data = mailString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        return data!
    }
    
    /*func getStatsForDisease() -> (Dictionary<String, Int>) {
        let realm = try! Realm()
        let 
        
    }*/

}
