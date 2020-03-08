//
//  Location.swift
//  AppFoundation
//
//  Created by Scheggia on 08/03/2020.
//  Copyright © 2020 Attio. All rights reserved.
//

import Foundation

public struct Location {
    public var latitude: Double
    public var longitude: Double
    public init(_ latitude: Double, _ longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public func distance(from location: Location) -> Double {
        let theta = longitude - location.longitude
        var dist = sin(deg2rad(deg: latitude))
            * sin(deg2rad(deg: location.latitude))
            + cos(deg2rad(deg: latitude))
            * cos(deg2rad(deg: location.latitude))
            * cos(deg2rad(deg: theta))
        dist = acos(dist)
        dist = rad2deg(rad: dist)
        dist = dist * 60 * 1.1515 * 1.609344
        return dist
    }

    private func deg2rad(deg: Double) -> Double {
        return deg * .pi / 180
    }

    private func rad2deg(rad: Double) -> Double {
        return rad * 180.0 / .pi
    }
}
