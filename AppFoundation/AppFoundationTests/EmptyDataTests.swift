//
//  EmptyDataTests.swift
//  AppFoundationTests
//
//  Created by Daniele Forlani on 07/08/2019.
//  Copyright © 2019 Attio. All rights reserved.
//

import XCTest
@testable import AppFoundation

class EmptyDataTests: XCTestCase {

    func test_build_shouldReturnEmptyData() {
        XCTAssertNotNil(EmptyData.build(from: Data()))
    }

}
