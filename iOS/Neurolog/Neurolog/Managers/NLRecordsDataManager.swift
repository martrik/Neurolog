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
    dynamic var teachingInfo: TeachingInfo?
    let visits = List<Visit>()
}

class Visit: Object {
    dynamic var time = NSDate()
    dynamic var topic = ""
    dynamic var sex = ""
    dynamic var age = 1
    var record: Record? {
        return linkingObjects(Record.self, forProperty: "visits").first
    }
}

class NLRecordsDataManager: NSObject {
    static let sharedInstance = NLRecordsDataManager()
    
    // MARK: Records
    
    func saveRecordWith(info: [String : Any?]) -> (Record) {
        var newRecord = Record()
        addPropertiesToRecord(&newRecord, info: info)
        
        let realm = try! Realm()
        
        try! realm.write {
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
            realm.delete(record)
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
    
    
    func recordsWithSetting(setting: String) -> ([Record]) {
        let realm = try! Realm()
        let settingRecords = realm.objects(Record).filter("setting = '\(setting)'")
        
        return Array(settingRecords)
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
            let cal = NSCalendar.currentCalendar()
            var hour = 0
            var minute = 0
            cal.getHour(&hour, minute: &minute, second: nil, nanosecond: nil, fromDate: time as! NSDate)
            let newDate: NSDate = cal.dateBySettingHour(hour, minute: minute, second: 0, ofDate: record.date, options: NSCalendarOptions())!
            
            newVisit.time = newDate
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
    
    func generateCSVWithRecord(record: Record) -> NSData {
        let mailString = NSMutableString()
        let timeFormatter = NSDateFormatter()
        timeFormatter.locale = NSLocale.currentLocale()
        timeFormatter.dateStyle = .MediumStyle
        timeFormatter.timeStyle = .NoStyle
        
        if record.teachingInfo == nil {
            mailString.appendString("Date, Setting, Location, Supervisor\n")
            
            let string = "\(timeFormatter.stringFromDate(record.date)), \(record.setting), \(record.location), " + (record.supervisor != nil ? record.supervisor!  : "none") + "\n"
            mailString.appendString(string)
            
            mailString.appendString("Time, Disease, Age, Sex\n")
            
            timeFormatter.dateStyle = .NoStyle
            timeFormatter.timeStyle = .ShortStyle
            
            for visit in record.visits {
                mailString.appendString("\(timeFormatter.stringFromDate(visit.time)), \(visit.topic), \(visit.age), \(visit.sex)\n")
            }
        } else {
            mailString.appendString("Date, Setting, Location, Title, Lecturer, Topic, Supervisor\n")
            
            let string = "\(timeFormatter.stringFromDate(record.date)), \(record.setting), \(record.location), \(record.teachingInfo!.title), \(record.teachingInfo!.lecturer), \(record.teachingInfo!.topic), " + (record.supervisor != nil ? record.supervisor!  : "none") + "\n"
            mailString.appendString(string)
        }
        
        
        mailString.appendString(" \n")
        
        // Converting it to NSData.
        let data = mailString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        return data!
    }
    
    
    func generateGeneralCSVWithRange(fromDate: NSDate, toDate: NSDate, teaching: Bool) -> NSData {
        let mailString = NSMutableString()
        let timeFormatter = NSDateFormatter()
        timeFormatter.locale = NSLocale.currentLocale()
        
        var stats = NLStatsManager.sharedInstance.statsForTopics(fromDate, to: toDate)
        var i = 0
        for topic in  stats.0 {
            mailString.appendString("\(topic), \(stats.1[i])\n")
            i += 1
        }
        
        if teaching {
            mailString.appendString(" \n")
            mailString.appendString("Teaching statistics\n")
            mailString.appendString("Disease, Teachings attended\n")
            
            let stats = NLStatsManager.sharedInstance.statsForTeaching(fromDate, to: toDate)
            for (topic, count) in stats {
                mailString.appendString("\(topic), \(count)\n")
            }
        }
        
        mailString.appendString(" \n")
        
        let data = mailString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        return data!
    }
    
    
    func generateDetailedCSVWithRange(fromDate: NSDate, toDate: NSDate, teaching: Bool) -> NSData {
        let mailString = NSMutableString()
        
        mailString.appendString("Detailed statistics for all topics\n")
        mailString.appendString(" \n")

        
        let topics = NLSelectionDataManger.sharedInstance.portfolioTopics()
        for topic in topics {
            mailString.appendString(detailedVisitsForTopic(topic, from: fromDate, to: toDate))
            mailString.appendString(" \n")
        }
        
        if teaching {
            let teachingRecords = NLStatsManager.sharedInstance.teachingByTopic(fromDate, to: toDate)
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.locale = NSLocale.currentLocale()
            dateFormatter.dateStyle = .MediumStyle
            
            mailString.appendString("Detailed statistics for teaching\n")
            
            for topic in topics {
                if teachingRecords[topic] != nil {
                    mailString.appendString("\(topic) teachings\n")
                    mailString.appendString("Date, Title, Lecturer, Location, Supervisor\n")
                    for record in teachingRecords[topic]! {
                        mailString.appendString("\(dateFormatter.stringFromDate(record.date)), \(record.teachingInfo!.title), \(record.teachingInfo!.lecturer), \(record.location), " + (record.supervisor != nil ? record.supervisor!  : "none") + "\n")
                    }
                    mailString.appendString(" \n")
                }
            }
        }
        
        let data = mailString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        return data!
    }
    
    
    func detailedVisitsForTopic(topic: String, from: NSDate, to: NSDate) -> String {
        let realm = try! Realm()
        let visitsWithTopic = realm.objects(Visit).filter("topic = '\(topic)' AND time <= %@ AND time >= %@", to, from)
        
        let string = NSMutableString()
        string.appendString("\(topic) cases\n")
        string.appendString("Date, Age, Sex, Location, Supervisor\n")
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateStyle = .MediumStyle
        
        for visit in visitsWithTopic {
            string.appendString("\(dateFormatter.stringFromDate(visit.time)), \(visit.age), \(visit.sex), \(visit.record!.location), " + (visit.record!.supervisor != nil ? visit.record!.supervisor!  : "none") + "\n")

        }
        
        return String(string)
    }
    

}
