//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Eduard Ptushko on 09.07.2026.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
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

    func testYesButton() throws {
        sleep(3)

        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["Yes"].tap()
        sleep(3)

        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]

        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }

    func testNoButton() throws {
        sleep(3)

        let firstPoster = app.images["Poster"]
        let firstPoserData = firstPoster.screenshot().pngRepresentation

        app.buttons["No"].tap()
        sleep(3)

        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]

        XCTAssertNotEqual(firstPoserData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }

    func testAlertShown() throws {
        let yesButton = app.buttons["Yes"]
        let alert = app.alerts["Alert"]

        XCTAssertTrue(yesButton.waitForExistence(timeout: 5))

        for _ in 1...10 {
            yesButton.tap()
            sleep(3)
        }

        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть еще раз")
    }

    func testAlertDismiss() {
        let yesButton = app.buttons["Yes"]
        let alert = app.alerts["Alert"]

        XCTAssertTrue(yesButton.waitForExistence(timeout: 5))

        for _ in 1...10 {
            yesButton.tap()
            sleep(3)
        }

        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons.firstMatch.tap()

        sleep(2)

        let indexLabel = app.staticTexts["Index"]

        XCTAssertFalse(alert.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
    }

}
