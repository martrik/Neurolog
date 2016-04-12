//
//  NLVisitsManager.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 12/04/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit
import RealmSwift

class Visit: Object {
    dynamic var time = NSDate()
    dynamic var topic = ""
    dynamic var sex = ""
    dynamic var age = 1
    var record: Record? {
        return linkingObjects(Record.self, forProperty: "visits").first
    }
}

class NLVisitsManager: NSObject {
    
    static let sharedInstance = NLVisitsManager()
    let realm = try! Realm()
    
    func saveVisitInRecord(record: Record, info: [String: Any?]) -> Visit? {
        var newVisit = Visit()
        
        try! realm.write {
            addPropertiesToVisit(&newVisit, record: record, info: info)
            record.visits.append(newVisit)
        }
        
        return record.visits.last
    }
    
    func updateVisit(visit: Visit, record: Record, info: [String: Any?]) {
        var updateVisit = visit
        
        try! realm.write {
            addPropertiesToVisit(&updateVisit, record: record, info: info)
        }
    }
    
    
    func addPropertiesToVisit(inout visit: Visit, record: Record, info: [String: Any?]) {
        if let time = info["time"] {
            let cal = NSCalendar.currentCalendar()
            var hour = 0
            var minute = 0
            cal.getHour(&hour, minute: &minute, second: nil, nanosecond: nil, fromDate: time as! NSDate)
            let newDate: NSDate = cal.dateBySettingHour(hour, minute: minute, second: 0, ofDate: record.date, options: NSCalendarOptions())!
            
            visit.time = newDate
        }
        if let disease = info["disease"] {
            visit.topic = disease as! String
        }
        if let age = info["age"] {
            visit.age = Int(age as! String)!
        }
        if let sex = info["sex"] {
            visit.sex = sex as! String!
        }
    }
    
    
    func deleteVisitFromRecord(visit: Visit, record: Record) {
        let realm = try! Realm()
        
        try! realm.write {
            record.visits.removeAtIndex(record.visits.indexOf(visit)!)
        }
    }
}
