//
//  TinkoffChatUITests.swift
//  TinkoffChatUITests
//
//  Created by Никита Казанцев on 06.05.2021.
//

import XCTest

class TinkoffChatUITests: XCTestCase {
    
    func testTextFields() throws {
        
        let app = XCUIApplication()
        app.launch()
        
        let button = app.navigationBars.buttons["Profile navigation button"]
        _ = button.waitForExistence(timeout: 5)
        button.tap()
        
        let userName = app.textFields["user name"]
        let userDescription = app.textViews["user description"]
        
        XCTAssert(userName.waitForExistence(timeout: 2))
        XCTAssert(userDescription.waitForExistence(timeout: 2))
        
    }
}
