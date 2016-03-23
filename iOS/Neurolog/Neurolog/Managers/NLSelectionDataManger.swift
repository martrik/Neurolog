//
//  SelectionDataManger.swift
//  Neurolog
//
//  Created by Martí Serra Vivancos on 06/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import UIKit

import SwiftyJSON

class NLSelectionDataManger: NSObject {
    static let sharedInstance = NLSelectionDataManger()
    
    func clinicalSettings() -> ([String]) {
        var facilities = [String]()
        
        for (_,subJson):(String, JSON) in getJSONObject()!["Setting"] {
            facilities.append(subJson.string!)
        }
        
        return facilities
    }
    
    func portfolioTopics() -> ([String]) {
        var portfolios = [String]()
        
        for (key,_):(String, JSON) in getJSONObject()!["Portfolio"] {
            portfolios.append(key)
        }
        
        portfolios.sortInPlace()
        
        return portfolios
    }
    
    
    func getJSONObject() -> (JSON?) {
        if let jsonData = NSData(contentsOfFile:NSBundle.mainBundle().pathForResource("data", ofType: "json")!) {
            let json = JSON(data: jsonData)
            return json
        } else {
            return nil
        }
    }

}
