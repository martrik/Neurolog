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

class RecordsDataManager: NSObject {
    static let sharedInstance = RecordsDataManager()
    
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
    
    func getAllRecords() -> ([Record]) {
        let realm = try! Realm()
        let allRecords = realm.objects(Record)
        
        return Array(allRecords)
    }

}
