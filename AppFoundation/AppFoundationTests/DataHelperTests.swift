//
//  DataHelperTests.swift
//  AppFoundationTests
//
//  Created by Daniele Forlani on 06/08/2019.
//  Copyright © 2019 Attio. All rights reserved.
//

import XCTest
@testable import AppFoundation

class DataHelperTests: XCTestCase {
    func test_escaped_shouldEscapeData() {
        let sut = "unescaped data \n".data(using: .utf8)
        let expectedResult = "unescaped data \\n".data(using: .utf8)
        XCTAssertEqual(sut?.escaped, expectedResult)
    }
}

import SwiftUI
class ArrayHeloperTests: XCTestCase {

    func test_escaped_shouldReturnCorrectEscapedData() {
        let sut = """
                    unescaped String \n contains \\\\
                  """.data(using: .utf8)
        guard let unescapedData = sut?.escaped else {
            return XCTFail("the data need to exist")
        }
        XCTAssertEqual(String(data: unescapedData, encoding: .utf8), "  unescaped String \\n contains \\\\")
    }
}
