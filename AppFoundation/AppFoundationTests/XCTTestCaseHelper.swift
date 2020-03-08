//
//  XCTTestCaseHelper.swift
//  AppFoundationTests
//
//  Created by Scheggia on 28/02/2020.
//  Copyright © 2020 Attio. All rights reserved.
//

import XCTest

extension XCTestCase {
    @discardableResult
    func setup(_ setupBlock: () -> Void) -> XCTestCase {
        setupBlock()
        return self
    }

    @discardableResult
    func test(_ testBlock: () -> Void) -> XCTestCase {
        testBlock()
        return self
    }

    @discardableResult
    func verify(_ verifyBlock: () -> Void) -> XCTestCase {
        verifyBlock()
        return self
    }
}
