//
//  AppcuesDestinationTests.swift
//  SegmentAppcuesTests
//
//  Created by Matt on 2021-10-06.
//  Copyright © 2021 Appcues. All rights reserved.
//

import XCTest
import Segment
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
}
