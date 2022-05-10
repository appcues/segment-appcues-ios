//
//  AppcuesDestinationTests.swift
//  SegmentAppcuesTests
//
//  Created by Matt on 2021-10-06.
//  Copyright © 2021 Appcues. All rights reserved.
//

import XCTest
import Segment
@testable import AppcuesKit
@testable import SegmentAppcues

class AppcuesDestinationTests: XCTestCase {

    func testRegister() throws {
        // Arrange
        let analytics = Analytics(configuration: Configuration(writeKey: "WRITE_KEY"))
        let appcuesDestination = AppcuesDestination()

        // Act
        analytics.add(plugin: appcuesDestination)

        // Assert
        XCTAssertNotNil(appcuesDestination.analytics)
    }

    func testConfiguration() throws {
        // Arrange
        let settingsPayload = #"""
        {
            "integrations": {
                "Appcues Mobile": {
                    "accountId": "00000",
                    "applicationId": "12345678-abcd-abcd-abcd-000000000000"
                }
            }
        }
        """#.data(using: .utf8)!
        let settings = try JSONDecoder().decode(Segment.Settings.self, from: settingsPayload)

        // Act
        let appcuesDestination = AppcuesDestination {
            $0.apiHost(URL(string: "https://api.appcues.com")!).sessionTimeout(32)
        }
        // This would get called in the process of `Analytics.add(plugin:)`, but call it directly to be able to inject our mock settings.
        appcuesDestination.update(settings: settings, type: .initial)

        // Assert
        let config = try XCTUnwrap(appcuesDestination.appcues?.config)
        XCTAssertEqual(config.sessionTimeout, 32)
        XCTAssertEqual(config.apiHost, URL(string: "https://api.appcues.com"))
    }
}
