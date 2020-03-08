//
//  LocatrionManager.swift
//  AppFoundation
//
//  Created by Scheggia on 08/03/2020.
//  Copyright © 2020 Attio. All rights reserved.
//

import Foundation
import CoreLocation

public protocol LocationManagerType {
    func requestAlwaysAuthorization()
    func startMonitoringSignificantLocationChanges()
    func stopMonitoringSignificantLocationChanges()
    func locationServicesEnabled() -> Bool
    func authorizationStatus() -> CLAuthorizationStatus
}
extension CLLocationManager: LocationManagerType {
    public func locationServicesEnabled() -> Bool {
        CLLocationManager.locationServicesEnabled()
    }

    public func authorizationStatus() -> CLAuthorizationStatus {
        CLLocationManager.authorizationStatus()
    }
}
