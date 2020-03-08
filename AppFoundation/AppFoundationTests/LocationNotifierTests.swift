//
//  LocationNotifierTests.swift
//  AppFoundationTests
//
//  Created by Scheggia on 06/03/2020.
//  Copyright © 2020 Attio. All rights reserved.
//

@testable import AppFoundation
import CoreLocation
import XCTest

class LocationNotifierTests: XCTestCase {

    var sut: LocationNotifier!
    var locationManager = MockLocationManager()

    override func setUp() {
        super.setUp()
        sut = LocationNotifier(locationManager: locationManager)
    }

    func test_requestAuthorization_shouldCallForAuthorization() {
        test {
            sut.requestAuthorization()
        }.verify {
            XCTAssertEqual(locationManager.requestAlwaysAuthorizationCounter, 1)
        }
    }

    func test_isEnabled_shouldReturnFalseWhenlocationServicesDisabled() {
        setup {
            locationManager.enabled = false
        }.verify {
            XCTAssertFalse(sut.isEnabled)
        }
    }

    func test_isEnabled_shouldReturnTrueWhenlocationServicesEnabled() {
        setup {
            locationManager.enabled = true
        }.verify {
            XCTAssertTrue(sut.isEnabled)
        }
    }

    func test_isAuthorized_shouldReturnFalseWhenlocationServicesEnabled_whenNotAuthorized() {
        setup {
            locationManager.enabled = true
            locationManager.status = .notDetermined
        }.verify {
            XCTAssertFalse(sut.isAuthorized)
        }
    }

    func test_isAuthorized_shouldReturnTrueWhenlocationServicesEnabled_alwaysAuthorized() {
        setup {
            locationManager.enabled = true
            locationManager.status = .authorizedAlways
        }.verify {
            XCTAssertTrue(sut.isAuthorized)
        }
    }

    func test_isAuthorized_shouldReturnTrueWhenlocationServicesEnabled_authorizedWhenInUse() {
        setup {
            locationManager.enabled = true
            locationManager.status = .authorizedWhenInUse
        }.verify {
            XCTAssertTrue(sut.isAuthorized)
        }
    }

    func test_start_shouldStartLocationManger() {
        test {
            sut.startMonitoring() { _ in }
        }.verify {
            XCTAssertEqual(locationManager.startMonitoringCounter, 1)
        }
    }

    func test_stop_shouldStartLocationManger() {
        test {
            sut.stopMonitoring()
        }.verify {
            XCTAssertEqual(locationManager.stopMonitoringCounter, 1)
        }
    }

    func test_didVisit_shouldCallbackWithCorrectLocation() {
        var locationChanged = 0
        setup {
            sut.startMonitoring { _ in locationChanged += 1 }
        }.test {
            sut.locationManager(CLLocationManager(), didVisit: CLVisit())
        }.verify {
            XCTAssertEqual(locationChanged, 1)
        }
    }
}
