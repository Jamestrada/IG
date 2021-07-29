//
//  IGTests.swift
//  IGTests
//
//  Created by James Estrada on 7/28/21.
//

@testable import IG

import XCTest

class IGTests: XCTestCase {

    func testNotificationIDCreation() {
        let first = NotificationsManager.newIdentifier()
        let second = NotificationsManager.newIdentifier()
        XCTAssertNotEqual(first, second)
    }
    
//    func testNotificationIDCreationFailure() {
//        let first = NotificationsManager.newIdentifier()
//        let second = NotificationsManager.newIdentifier()
//        XCTAssertEqual(first, second)
//    }
}
