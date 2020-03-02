//
//  DateHelper.swift
//  AppFoundation
//
//  Created by Daniele Forlani on 12/08/2019.
//  Copyright © 2019 Attio. All rights reserved.
//

import Foundation

extension Date {
    public var agoLong: String {
        let secondsAgo = Int(Date().timeIntervalSince(self))

        let minute = 60
        let minutes = 60 * 2
        let hour = 60 * minute
        let hours = 60 * minute * 2
        let day = 24 * hour
        let days = 24 * hour * 2
        let week = 7 * day
        let weeks = 7 * day * 2
        let month = 30 * day
        let months = 30 * day * 2
        let year = 12 * month
        let years = 12 * month * 2

        switch secondsAgo {
        case let seconds where seconds < minute : return "\(secondsAgo) \(DisplayTime.long.seconds) ago"
        case let seconds where seconds < minutes : return "\(secondsAgo / minute) \(DisplayTime.long.minute) ago"
        case let seconds where seconds < hour: return "\(secondsAgo / minute) \(DisplayTime.long.minutes) ago"
        case let seconds where seconds < hours: return "\(secondsAgo / hour) \(DisplayTime.long.hour) ago"
        case let seconds where seconds < day: return "\(secondsAgo / hour) \(DisplayTime.long.hours) ago"
        case let seconds where seconds < days: return "\(secondsAgo / day) \(DisplayTime.long.day) ago"
        case let seconds where seconds < week: return "\(secondsAgo / day) \(DisplayTime.long.days) ago"
        case let seconds where seconds < weeks: return "\(secondsAgo / week) \(DisplayTime.long.week) ago"
        case let seconds where seconds < month: return "\(secondsAgo / week) \(DisplayTime.long.weeks) ago"
        case let seconds where seconds < months: return "\(secondsAgo / month) \(DisplayTime.long.month) ago"
        case let seconds where seconds < year: return "\(secondsAgo / month) \(DisplayTime.long.months) ago"
        case let seconds where seconds < years: return "\(secondsAgo / year) \(DisplayTime.long.year) ago"
        default: return "\(secondsAgo / year) \(DisplayTime.long.years) ago" }
    }

    public var agoShort: String {
        let secondsAgo = Int(Date().timeIntervalSince(self))

        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 30 * day
        let year = 12 * month

        switch secondsAgo {
        case let seconds where seconds < minute : return "\(secondsAgo)\(DisplayTime.short.seconds) ago"
        case let seconds where seconds < hour: return "\(secondsAgo / minute)\(DisplayTime.short.minutes) ago"
        case let seconds where seconds < day: return "\(secondsAgo / hour)\(DisplayTime.short.hours) ago"
        case let seconds where seconds < week: return "\(secondsAgo / day)\(DisplayTime.short.days) ago"
        case let seconds where seconds < month: return "\(secondsAgo / week)\(DisplayTime.short.weeks) ago"
        case let seconds where seconds < year: return "\(secondsAgo / month)\(DisplayTime.short.months) ago"
        default: return "\(secondsAgo / year)\(DisplayTime.short.years) ago" }
    }

    public var sent: String {
        let secondsAgo = Int(Date().timeIntervalSince(self))

        let minute = 60
        let minutes = 60 * 2
        let hour = 60 * minute
        let hours = 60 * minute * 2
        let day = 24 * hour
        let days = 24 * hour * 2
        let week = 7 * day
        let weeks = 7 * day * 2
        let month = 30 * day
        let months = 30 * day * 2
        let year = 12 * month
        let years = 12 * month * 2

        sentTimeFormatter.dateFormat = "hh:mm a"
        sentDateFormatter.dateFormat = "dd MMM"
        sentDateYearFormatter.dateFormat = "dd MMM YY"

        switch secondsAgo {
        case let seconds where seconds < minute : return sentTimeFormatter.string(from: self)
        case let seconds where seconds < minutes : return sentTimeFormatter.string(from: self)
        case let seconds where seconds < hour: return sentTimeFormatter.string(from: self)
        case let seconds where seconds < hours: return sentTimeFormatter.string(from: self)
        case let seconds where seconds < day: return "yesterday, " + sentTimeFormatter.string(from: self)
        case let seconds where seconds < days: return sentDateFormatter.string(from: self)
        case let seconds where seconds < week: return sentDateFormatter.string(from: self)
        case let seconds where seconds < weeks: return sentDateFormatter.string(from: self)
        case let seconds where seconds < month: return sentDateFormatter.string(from: self)
        case let seconds where seconds < months: return sentDateFormatter.string(from: self)
        case let seconds where seconds < year: return sentDateFormatter.string(from: self)
        case let seconds where seconds < years: return sentDateFormatter.string(from: self)
        default:
            return sentDateYearFormatter.string(from: self)

        }
    }
}
