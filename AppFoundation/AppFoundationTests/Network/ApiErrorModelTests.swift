//
//  ApiErrorModelTests.swift
//  AppFoundationTests
//
//  Created by Daniele Forlani on 25/07/2019.
//  Copyright © 2019 Attio. All rights reserved.
//

import XCTest
import AppFoundation
@testable import AppFoundation

class APIErrorModelTests: XCTestCase {

    func test_init_shouldInitWithNSError() {
        let apiError = ApiError.build(with: NSError(domain: "ErrorDomain",
                                                    code: 2443,
                                                    userInfo: [errorMessageKey: "Error message"]))
        XCTAssertEqual(apiError.code, 2443)
        XCTAssertEqual(apiError.message, "ErrorDomain: Error message")
    }
}
