//
//  CGPointHelper.swift
//  AppFoundation
//
//  Created by Daniele Forlani on 18/11/2019.
//  Copyright © 2019 Attio. All rights reserved.
//

import SwiftUI

extension CGPoint: VectorArithmetic {

    public static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    public static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public mutating func scale(by rhs: Double) {
        x *= CGFloat(rhs)
        y *= CGFloat(rhs)
    }

    public var magnitudeSquared: Double {
        Double( x * x + y * y)
    }

    public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}
