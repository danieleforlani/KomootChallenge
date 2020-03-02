//
//  SchedulerTests.swift
//  AppFoundationTests
//
//  Created by Daniele Forlani on 09/08/2019.
//  Copyright © 2019 Attio. All rights reserved.
//

@testable import AppFoundation
import XCTest

class SchedulerTests: XCTestCase {

    var sut: Scheduler!
    var executionCounter = 0

    override func setUp() {
        super.setUp()
        sut = Scheduler(identifier: "SchedulerTest")
        sut.timerType = MockTimer.self as TimerType.Type
    }

    func test_schedule_shouldCreateATimer() {
        sut.invalidateAndReschedule(at: 10) {  self.executionCounter += 1 }
        XCTAssertNotNil(sut.timer)
        guard let date = sut.timer?.fireDate else {
            return XCTFail("The date is not set")
        }
        XCTAssertTrue(date > Date())
    }

    func test_schedule_shouldSetAtimer_whenTimerFireCallTheBlock() {
        let expect = expectation(description: "should be scheduled in the future")
        sut = Scheduler(identifier: "test_schedule_withTime_shouldCallBlockOnce")
        sut.invalidateAndReschedule(at: 0) {
            self.executionCounter += 1
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)
        XCTAssertEqual(executionCounter, 1)
    }

    func test_schedule_should_invalidatePreviousScheduledTimer() {
        sut.invalidateAndReschedule(at: 10) {  self.executionCounter += 1 }
        let oldTimer = sut.timer as? MockTimer
        sut.invalidateAndReschedule(at: 10) {  self.executionCounter += 1 }
        XCTAssertEqual(oldTimer?.invalidateCounter, 1)
        XCTAssertEqual(oldTimer?.isValid, false)

        let newTimer = sut.timer as? MockTimer
        XCTAssertEqual(newTimer?.invalidateCounter, 0)
        XCTAssertEqual(newTimer?.isValid, true)
    }
}
