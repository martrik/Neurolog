//
//  NLExportManager.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 12/04/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit
import RealmSwift

class NLExportManager: NSObject {
    static let sharedInstance = NLExportManager()

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
        
        
        let topics = NLSelectionManager.sharedInstance.portfolioTopics()
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
