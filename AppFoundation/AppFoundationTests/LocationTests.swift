//
//  LocationTests.swift
//  AppFoundationTests
//
//  Created by Scheggia on 08/03/2020.
//  Copyright © 2020 Attio. All rights reserved.
//

@testable import AppFoundation
import XCTest

class LocationTests: XCTestCase {

    var sut = Location(1, 1)

    func test_distance_shouldRetunCorrectValue_differentLatitude() {
        let location = Location(2, 1)
        XCTAssertEqual(sut.distance(from: location).rounded(), 111)
    }

    func test_distance_shouldRetunCorrectValue_differentLongitude() {
        let location = Location(1, 2)
        XCTAssertEqual(sut.distance(from: location).rounded(), 111)
    }

    func test_distance_shouldRetunCorrectValue_differentLatitudeAndLongitude() {
        let location = Location(2, 2)
        XCTAssertEqual(sut.distance(from: location).rounded(), 157)
    }
}
