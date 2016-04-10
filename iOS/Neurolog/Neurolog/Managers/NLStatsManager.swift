//
//  NLStatsManager.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 20/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import Foundation
import RealmSwift

class NLStatsManager: NSObject {
    static let sharedInstance = NLStatsManager()
    
    func statsForClinicalSettings() -> ([String], [Int]) {
        let settings = NLSelectionManager.sharedInstance.clinicalSettings()
        var settingsCount = [Int]()
        let realm = try! Realm()

        for key in settings {
            settingsCount.append(realm.objects(Record).filter("setting = '\(key)'").count)
        }

        return (settings, settingsCount)
    }
    
    
    func statsForAgeRanges() -> ([String], [Int]) {
        let agesRanges = ["0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "110"]
        let realm = try! Realm()
        var ageRangesCount = [Int]()

        for age in agesRanges {
            ageRangesCount.append(realm.objects(Visit).filter("age >= \(age) AND age <\(Int(age)!+9)").count)
        }
        
        return (agesRanges, ageRangesCount)
    }
    
    
    func statsForTopics(from: NSDate, to: NSDate) -> ([String], [Int]) {
        let topics = NLSelectionManager.sharedInstance.portfolioTopics()
        var topicsCount = [Int]()
        let realm = try! Realm()
        
        for key in topics {
            topicsCount.append(realm.objects(Visit).filter("topic = '\(key)' AND time <= %@ AND time >= %@", to, from).count)
        }
        
        return (topics, topicsCount)
    }
    
    
    func statsForTeaching(from: NSDate, to: NSDate) -> Dictionary<String, Int> {
        var result = [String : Int]()
        let realm = try! Realm()
        
        let objects = realm.objects(Record).filter("setting = 'Teaching' AND date <= %@ AND date >= %@", to, from)
        
        for record in objects {
            if result[(record.teachingInfo?.topic)!] != nil {
                result[(record.teachingInfo?.topic)!] = result[(record.teachingInfo?.topic)!]! + 1
            } else {
                result[(record.teachingInfo?.topic)!] = 1
            }
        }
        
        return result
    }
    
    
    func teachingByTopic(from: NSDate, to: NSDate) -> Dictionary<String, [Record]> {
        var result = [String : [Record]]()
        let realm = try! Realm()
        
        let teachingRecords = realm.objects(Record).filter("setting = 'Teaching' AND date <= %@ AND date >= %@", to, from)
        
        for record in teachingRecords {
            if result[(record.teachingInfo?.topic)!] == nil {
                result[(record.teachingInfo?.topic)!] = [record]
            } else {
                result[(record.teachingInfo?.topic)!]!.append(record)
            }
        }
        
        return result
    }
}