//
//  XCTTestCaseHelper.swift
//  AppFoundationTests
//
//  Created by Scheggia on 28/02/2020.
//  Copyright © 2020 Attio. All rights reserved.
//

import XCTest

public extension XCTestCase {

    @discardableResult
    public func setup(_ setupBlock: () -> Void) -> XCTestCase {
        setupBlock()
        return self
    }

    @discardableResult
    public func test(_ testBlock: () -> Void) -> XCTestCase {
        testBlock()
        return self
    }

    @discardableResult
    public func verify(_ verifyBlock: () -> Void) -> XCTestCase {
        verifyBlock()
        return self
    }
}
