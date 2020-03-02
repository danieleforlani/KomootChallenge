//
//  Enums.swift
//  
//
//  Created by Daniele Forlani on 14/03/2019.
//  Copyright © 2019 Attio. All rights reserved.
//

import Foundation

enum ConfigurationArguments: String {
    case uiTests
}

public enum DisplayTime {
    case short
    case long

    var seconds: String {
        switch self {
        case .short: return "s"
        case .long: return "seconds"
        }
    }

    var minute: String {
        switch self {
        case .short: return "m"
        case .long: return "minute"
        }
    }

    var minutes: String {
        switch self {
        case .short: return "m"
        case .long: return "minutes"
        }
    }

    var hour: String {
        switch self {
        case .short: return "h"
        case .long: return "hour"
        }
    }

    var hours: String {
        switch self {
        case .short: return "h"
        case .long: return "hours"
        }
    }

    var day: String {
        switch self {
        case .short: return "d"
        case .long: return "day"
        }
    }

    var days: String {
        switch self {
        case .short: return "d"
        case .long: return "days"
        }
    }

    var week: String {
        switch self {
        case .short: return "w"
        case .long: return "week"
        }
    }

    var weeks: String {
        switch self {
        case .short: return "w"
        case .long: return "weeks"
        }
    }

    var month: String {
        switch self {
        case .short: return "M"
        case .long: return "month"
        }
    }

    var months: String {
        switch self {
        case .short: return "M"
        case .long: return "months"
        }
    }

    var year: String {
        switch self {
        case .short: return "y"
        case .long: return "year"
        }
    }

    var years: String {
        switch self {
        case .short: return "y"
        case .long: return "years"
        }
    }
}
