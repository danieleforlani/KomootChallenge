//
//  XCTTestCaseHelper.swift
//  LittleWalkTests
//
//  Created by Scheggia on 06/03/2020.
//  Copyright © 2020 Flowprocess. All rights reserved.
//

import XCTest

public extension XCTestCase {

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

