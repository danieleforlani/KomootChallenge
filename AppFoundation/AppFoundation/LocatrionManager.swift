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
    var delegate: CLLocationManagerDelegate? { get set }
    var distanceFilter: CLLocationDistance { get set }
    var allowsBackgroundLocationUpdates: Bool { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }
    func requestAlwaysAuthorization()
    func startMonitoring()
    func stopMonitoring()
    func locationServicesEnabled() -> Bool
    func authorizationStatus() -> CLAuthorizationStatus

}
extension CLLocationManager: LocationManagerType {

    public func startMonitoring() {
        requestLocation()
        startUpdatingLocation()
    }

    public func stopMonitoring() {
        stopUpdatingLocation()
    }

    public func locationServicesEnabled() -> Bool {
        CLLocationManager.locationServicesEnabled()
    }

    public func authorizationStatus() -> CLAuthorizationStatus {
        CLLocationManager.authorizationStatus()
    }
}
