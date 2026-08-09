//
//  Smart_Day_PlannerUITests.swift
//  Smart Day PlannerUITests
//
//  Created by Vidhi Dave on 7/3/26.
//

import XCTest

final class Smart_Day_PlannerUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages",
            "(en)",
            "-AppleLocale",
            "en_US"
        ]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testAppLaunchesSuccessfully() throws {
        app.launch()

        XCTAssertTrue(
            app.wait(
                for: .runningForeground,
                timeout: 5
            )
        )
    }

    @MainActor
    func testAuthenticationScreenAppearsWhenSignedOut() throws {
        app.launch()

        let title = app.staticTexts["Smart Day Planner"]

        XCTAssertTrue(
            title.waitForExistence(timeout: 5),
            "Expected the Smart Day Planner authentication screen to appear."
        )
    }

    @MainActor
    func testAuthenticationScreenShowsPlannerDescription() throws {
        app.launch()

        let description = app.staticTexts[
            "Plan your day with AI-powered scheduling around your tasks and calendar."
        ]

        XCTAssertTrue(
            description.waitForExistence(timeout: 5),
            "Expected the planner description to be visible."
        )
    }

    @MainActor
    func testAuthenticationScreenShowsSignInInstructions() throws {
        app.launch()

        let instructions = app.staticTexts[
            "Sign in with Google to start planning your day."
        ]

        XCTAssertTrue(
            instructions.waitForExistence(timeout: 5),
            "Expected Google sign-in instructions to be visible."
        )
    }

    @MainActor
    func testAuthenticationScreenContainsGoogleSignInControl() throws {
        app.launch()

        let googleButton = app.buttons.matching(
            NSPredicate(
                format: "label CONTAINS[c] %@",
                "Google"
            )
        ).firstMatch

        XCTAssertTrue(
            googleButton.waitForExistence(timeout: 5),
            "Expected a Google sign-in control to be available."
        )

        XCTAssertTrue(
            googleButton.isHittable,
            "Expected the Google sign-in control to be interactive."
        )
    }

    @MainActor
    func testAuthenticationScreenHasNoUnexpectedErrorOnLaunch() throws {
        app.launch()

        let title = app.staticTexts["Smart Day Planner"]

        XCTAssertTrue(
            title.waitForExistence(timeout: 5)
        )

        XCTAssertFalse(
            app.staticTexts[
                "Google Sign-In is not configured."
            ].exists,
            "The app should not report missing Google Sign-In configuration during a normal configured launch."
        )
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(
            metrics: [
                XCTApplicationLaunchMetric()
            ]
        ) {
            XCUIApplication().launch()
        }
    }
}
