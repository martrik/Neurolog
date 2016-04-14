//
//  NeurologUITests.swift
//  NeurologUITests
//
//  Created by Martí Serra Vivancos on 03/03/16.
//  Copyright © 2016 MartiSerra. All rights reserved.
//

import XCTest

class NLRecordsUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }
    
    
    func testAddRecord() {
        let app = XCUIApplication()
        app.buttons["Summary"].tap()
        app.buttons["All"].tap()
        app.navigationBars["Neurolog"].buttons["Add"].tap()
        
        let locationCellsQuery = app.tables.cells.containingType(.StaticText, identifier:"Location:")
        locationCellsQuery.childrenMatchingType(.TextField).element.tap()
        locationCellsQuery.childrenMatchingType(.TextField).element.typeText("UCLH")
        
        app.tables.staticTexts["Neurology on call"].tap()
        app.alerts.collectionViews.buttons["Ward referral"].tap()
        
        app.navigationBars["Add record"].buttons["Save"].tap()
        
        XCTAssert(app.staticTexts["Setting: Ward referral"].exists)
        XCTAssert(app.staticTexts["Location: UCLH"].exists)
        XCTAssert(app.staticTexts["Supervisor: none"].exists)
        
        app.navigationBars["Record"].buttons["Neurolog"].tap()
        
        XCTAssert(app.staticTexts["Ward referral"].exists)
        XCTAssert(app.staticTexts["UCLH"].exists)
    }
    
    func testAddRecordAndVisit() {
        let app = XCUIApplication()
        
        // Add record first
        app.navigationBars["Neurolog"].buttons["Add"].tap()
        let locationCellsQuery = app.tables.cells.containingType(.StaticText, identifier:"Location:")
        locationCellsQuery.childrenMatchingType(.TextField).element.tap()
        locationCellsQuery.childrenMatchingType(.TextField).element.typeText("UCLH")
        app.tables.staticTexts["Neurology on call"].tap()
        app.alerts.collectionViews.buttons["Ward referral"].tap()
        app.navigationBars["Add record"].buttons["Save"].tap()
    
        // Add visit
        app.navigationBars["Record"].buttons["Add"].tap()
        
        app.tables.staticTexts["Disease:"].tap()
        app.tables.staticTexts["Disorders of Sleep"].tap()
        
        app.tables.staticTexts["Age:"].tap()
        app.tables.staticTexts["24"].tap()
        
        app.tables.staticTexts["Sex:"].tap()
        app.sheets.collectionViews.buttons["Female"].tap()
        
        app.navigationBars["Add case"].buttons["Save"].tap()
                
        XCTAssert(app.staticTexts["Sex: Female Age: 24"].exists)
        XCTAssert(app.staticTexts["Disorders of Sleep"].exists)
    }
}
