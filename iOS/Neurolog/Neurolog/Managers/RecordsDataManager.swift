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
    dynamic var name = ""
    dynamic var age = 0
}

class RecordsDataManager: NSObject {
    static let sharedInstance = SelectionDataManger()


}
