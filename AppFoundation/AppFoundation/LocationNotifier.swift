//
//  LocationNotifier.swift
//  AppFoundation
//
//  Created by Scheggia on 06/03/2020.
//  Copyright © 2020 Attio. All rights reserved.
//

import Foundation
import CoreLocation

public protocol LocationNotifierType: CLLocationManagerDelegate {
    var isAuthorized: Bool { get }
    var isEnabled: Bool { get }
    func startMonitoring(onLocationChange: @escaping (Location) -> Void)
    func stopMonitoring()
    func requestAuthorization()
}

public class LocationNotifier: NSObject {
    private var locationManager: LocationManagerType
    private var onLocation: ((Location) -> Void)?

    public init(locationManager: LocationManagerType = CLLocationManager()) {
        self.locationManager  = locationManager
    }
}

extension LocationNotifier: LocationNotifierType {

    public var isAuthorized: Bool {
        (locationManager.authorizationStatus() == .authorizedAlways
        || locationManager.authorizationStatus() == .authorizedWhenInUse)
    }

    public var isEnabled: Bool {
        locationManager.locationServicesEnabled()
    }

    public func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    public func startMonitoring(onLocationChange: @escaping (Location) -> Void) {
        locationManager.startMonitoringSignificantLocationChanges()
        onLocation = onLocationChange
    }

    public func stopMonitoring() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
}

extension LocationNotifier {
    public func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        onLocation?(Location(visit.coordinate.latitude,
                            visit.coordinate.longitude))
    }
}
