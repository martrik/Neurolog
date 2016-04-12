//
//  RecordsDataManager.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 13/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit
import RealmSwift

class TeachingInfo: Object {
    dynamic var topic = ""
    dynamic var lecturer = ""
    dynamic var title = ""
}

class Record: Object {
    dynamic var date = NSDate()
    dynamic var location = ""
    dynamic var setting = ""
    dynamic var supervisor: String? = nil
    dynamic var signaturePath: String? = nil
    dynamic var teachingInfo: TeachingInfo? = nil
    let visits = List<Visit>()
}

class NLRecordsManager: NSObject {
    static let sharedInstance = NLRecordsManager()
    
    // MARK: Records
    
    func saveRecordWith(info: [String : Any?]) -> (Record) {
        var newRecord = Record()
        
        let realm = try! Realm()
        
        try! realm.write {
            addPropertiesToRecord(&newRecord, info: info)
            realm.add(newRecord)
        }
        
        return newRecord
    }
    
    
    func updateRecord(record: Record, info: [String : Any?]) {
        let realm = try! Realm()
        var updateRecord = record
        
        try! realm.write {
            addPropertiesToRecord(&updateRecord, info: info)
        }
    }
    
    
    func addPropertiesToRecord(inout record: Record, info: [String : Any?]) -> (Record) {
        if let date = info["date"] {
            record.date = date as! NSDate
        }
        if let location = info["location"] {
            record.location = location as! String
        }
        if let setting = info["setting"] {
            record.setting = setting as! String
            
            if record.setting == "Teaching" {
                let teaching = TeachingInfo()
                teaching.title = info["teachingtitle"] as! String
                teaching.topic = info["teachingtopic"] as! String
                teaching.lecturer = info["teachinglecturer"] as! String
                
                let realm = try! Realm()
                realm.add(teaching)
                
                record.teachingInfo = teaching
            } else {
                record.teachingInfo = nil
            }
        }
        
        if let supervisor = info["supervisorname"] {
            if supervisor as? String != record.supervisor {
                record.signaturePath = nil
            }
            record.supervisor = supervisor as? String
        } else {
            record.signaturePath = nil
            record.supervisor = nil
        }
    
        return record
    }
    
    
    func deleteRecord(record: Record) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.delete(record.visits)
            realm.delete(record)
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
    
    
    func recordsWithSetting(setting: String) -> ([Record]) {
        let realm = try! Realm()
        let settingRecords = realm.objects(Record).filter("setting = '\(setting)'")
        
        return Array(settingRecords)
    }  

}
