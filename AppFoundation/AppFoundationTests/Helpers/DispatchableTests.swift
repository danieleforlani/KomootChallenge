//
//  DispatchableTests.swift
//  MarksAndSpencerTests
//
//  Created by Daniele Forlani on 13/10/2018.
//  Copyright © 2018 Scheggia. All rights reserved.
//

import XCTest
@testable import AppFoundation

class DispatchableTests: XCTestCase {

    var sut = Dispatchable()

    func test_main_shouldCallBlockOnMainThread() {
        let expect = expectation(description: #function)

        sut.mainAsync {
            XCTAssertTrue(Thread.current.isMainThread)
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)
    }

    func test_mainAsyncAfter_shouldCallBlockOnMainThread() {
        let expect = expectation(description: #function)

        sut.mainAsync(after: 25) {
            XCTAssertTrue(Thread.current.isMainThread)
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)
    }
}
