//
//  Smart_Day_PlannerUITestsLaunchTests.swift
//  Smart Day PlannerUITests
//
//  Created by Vidhi Dave on 7/3/26.
//

import XCTest

final class Smart_Day_PlannerUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()

        app.launchArguments += [
            "-AppleLanguages",
            "(en)",
            "-AppleLocale",
            "en_US"
        ]

        app.launch()

        XCTAssertTrue(
            app.wait(
                for: .runningForeground,
                timeout: 5
            ),
            "Expected Smart Day Planner to launch into the foreground."
        )

        XCTAssertTrue(
            app.staticTexts["Smart Day Planner"]
                .waitForExistence(timeout: 5),
            "Expected the main authentication screen after launch."
        )

        let attachment = XCTAttachment(
            screenshot: app.screenshot()
        )

        attachment.name = "Smart Day Planner Launch"
        attachment.lifetime = .keepAlways

        add(attachment)
    }
}
