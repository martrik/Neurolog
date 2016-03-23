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
        let settings = NLSelectionDataManger.sharedInstance.clinicalSettings()
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
}