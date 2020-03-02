//
//  DateHelperTests.swift
//  AppFoundationTests
//
//  Created by Daniele Forlani on 12/08/2019.
//  Copyright © 2019 Attio. All rights reserved.
//

import XCTest
@testable import AppFoundation

class DateHelperTests: XCTestCase {

    func test_agoLong_shouldDisplaySecondsAgo() {
        let oldDate = Date().addingTimeInterval(-11)
        XCTAssertEqual(oldDate.agoLong, "11 seconds ago")
    }

    func test_agoShort_shouldDisplaySecondsAgo() {
        let oldDate = Date().addingTimeInterval(-11)
        XCTAssertEqual(oldDate.agoShort, "11s ago")
    }

    func test_agoLong_shouldDisplayOneMinuteAgo() {
        let oldDate = Date().addingTimeInterval(-71)
        XCTAssertEqual(oldDate.agoLong, "1 minute ago")
    }

    func test_agoShort_shouldDisplayOneMinuteAgo() {
        let oldDate = Date().addingTimeInterval(-71)
        XCTAssertEqual(oldDate.agoShort, "1m ago")
    }

    func test_agoLong_shouldDisplayMinutesAgo() {
        let oldDate = Date().addingTimeInterval(-(20 * 60 + 2))
        XCTAssertEqual(oldDate.agoLong, "20 minutes ago")
    }

    func test_agoShort_shouldDisplayMinutesAgo() {
        let oldDate = Date().addingTimeInterval(-(20 * 60 + 2))
        XCTAssertEqual(oldDate.agoShort, "20m ago")
    }

    func test_agoLong_shouldDisplayOneHourAgo() {
        let oldDate = Date().addingTimeInterval(-(63 * 60))
        XCTAssertEqual(oldDate.agoLong, "1 hour ago")
    }

    func test_agoShort_shouldDisplayOneHourAgo() {
        let oldDate = Date().addingTimeInterval(-(63 * 60))
        XCTAssertEqual(oldDate.agoShort, "1h ago")
    }

    func test_agoLong_shouldDisplayHoursAgo() {
        let oldDate = Date().addingTimeInterval(-(20 * 60 * 60 + 2))
        XCTAssertEqual(oldDate.agoLong, "20 hours ago")
    }

    func test_agoShort_shouldDisplayHoursAgo() {
        let oldDate = Date().addingTimeInterval(-(20 * 60 * 60 + 2))
        XCTAssertEqual(oldDate.agoShort, "20h ago")
    }

    func test_agoLong_shouldDisplayOneDayAgo() {
        let oldDate = Date().addingTimeInterval(-(26 * 60 * 60 + 2))
        XCTAssertEqual(oldDate.agoLong, "1 day ago")
    }

    func test_agoShort_shouldDisplayOneDayAgo() {
        let oldDate = Date().addingTimeInterval(-(26 * 60 * 60 + 2))
        XCTAssertEqual(oldDate.agoShort, "1d ago")
    }

    func test_agoLong_shouldDisplayDaysAgo() {
        let oldDate = Date().addingTimeInterval(-(56 * 60 * 60 + 2))
        XCTAssertEqual(oldDate.agoLong, "2 days ago")
    }

    func test_agoShort_shouldDisplayDaysAgo() {
        let oldDate = Date().addingTimeInterval(-(56 * 60 * 60 + 2))
        XCTAssertEqual(oldDate.agoShort, "2d ago")
    }

    func test_agoLong_shouldDisplayOneMonthAgo() {
        let oldDate = Date().addingTimeInterval(-(32 * 24 * 60 * 60 + 2))
        XCTAssertEqual(oldDate.agoLong, "1 month ago")
    }

    func test_agoShort_shouldDisplayOneMonthAgo() {
        let oldDate = Date().addingTimeInterval(-(32 * 24 * 60 * 60 + 2))
        XCTAssertEqual(oldDate.agoShort, "1M ago")
    }

    func test_agoLong_shouldDisplayMonthsAgo() {
        let oldDate = Date().addingTimeInterval(-(90 * 24 * 3600 + 2))
        XCTAssertEqual(oldDate.agoLong, "3 months ago")
    }

    func test_agoShort_shouldDisplayMonthsAgo() {
        let oldDate = Date().addingTimeInterval(-(90 * 24 * 3600 + 2))
        XCTAssertEqual(oldDate.agoShort, "3M ago")
    }

    func test_agoLong_shouldDisplayOneYearAgo() {
        let oldDate = Date().addingTimeInterval(-(360 * 24 * 3600 + 2))
        XCTAssertEqual(oldDate.agoLong, "1 year ago")
    }

    func test_agoShort_shouldDisplayOneYearAgo() {
        let oldDate = Date().addingTimeInterval(-(360 * 24 * 3600 + 2))
        XCTAssertEqual(oldDate.agoShort, "1y ago")
    }

    func test_agoLong_shouldDisplayYearsAgo() {
        let oldDate = Date().addingTimeInterval(-(860 * 24 * 3600 + 2))
        XCTAssertEqual(oldDate.agoLong, "2 years ago")

    }

    func test_agoShort_shouldDisplayYearsAgo() {
        let oldDate = Date().addingTimeInterval(-(860 * 24 * 3600 + 2))
        XCTAssertEqual(oldDate.agoShort, "2y ago")
    }

    func test_sent_shouldDisplaySecondsAgo() {
        let oldDate = Date().setTime(hour: 5, min: 56, sec: 11)
        XCTAssertEqual(oldDate?.sent, "yesterday, 05:56 AM")
    }

    func test_sent_shouldDisplayDaysAgo() {
        let oldDate = Date().setYear(year: 2019, month: 12, day: 12)?.setTime(hour: 11, min: 09, sec: 00)
        XCTAssertEqual(oldDate?.sent, "11:09 AM")
    }
}

extension Date {
    public func setTime(hour: Int, min: Int, sec: Int, timeZoneAbbrev: String = "UTC") -> Date? {
        let comp: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cal = Calendar.current
        var components = cal.dateComponents(comp, from: self)

        components.hour = hour
        components.minute = min
        components.second = sec

        return cal.date(from: components)
    }

    public func setYear(year: Int, month: Int, day: Int, timeZoneAbbrev: String = "UTC") -> Date? {
        let comp: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cal = Calendar.current
        var components = cal.dateComponents(comp, from: self)

        components.year = year
        components.day = year
        components.year = year

        return cal.date(from: components)
    }
}
