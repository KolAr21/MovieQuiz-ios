//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Арина Колганова on 20.09.2023.
//

import XCTest

class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        app.buttons["Yes"].tap()
        sleep(3)
        let secondPoster = app.images["Poster"]
        
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertEqual(indexLabel.label, "2/10")
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertTrue(firstPoster.exists)
        XCTAssertTrue(secondPoster.exists)
    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertEqual(indexLabel.label, "2/10")
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertTrue(firstPoster.exists)
        XCTAssertTrue(secondPoster.exists)
        
    }
    
    func testFinishGame() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Alert"]
        sleep(2)
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }
    
    func testAlertButton() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Alert"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
    }
    
}
