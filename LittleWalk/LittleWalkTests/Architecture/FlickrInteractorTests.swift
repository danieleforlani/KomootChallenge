//
//  FlickrInteractorTests.swift
//  LittleWalkTests
//
//  Created by Scheggia on 06/03/2020.
//  Copyright © 2020 Flowprocess. All rights reserved.
//

@testable import LittleWalk
import AppFoundation
import CoreData
import SwiftUI
import XCTest

class FlickrInteractorTests: XCTestCase {

    var sut: FlickrInteractor!
    var locationNotifier = MockLocationNotifier()
    var persistentContainer = MockPersistentContainer()
    var dataStore: MockDataStore!
    var container = InjectionContainer()
    var contentViewModel = ContentViewModel()
    var api = MockFlickrAPI()
    var dispatchable = MockDispatchable()

    override func setUp() {
        super.setUp()
        dataStore = MockDataStore(store: storeName,
                                  container: persistentContainer)
        sut = FlickrInteractor(locationNotifier: locationNotifier,
                               dataStore: dataStore,
                               api: api,
                               container: container,
                               dispatchable: dispatchable)
    }

    func test_init_shouldAddDataStore_inContainer() {
        let dataStore = container.resolve(DataStoreType.self)
        XCTAssertEqual("\(String(describing: dataStore))", "\(String(describing: self.dataStore))")
    }

    func test_init_shouldRequestAccessToLocation() {
        XCTAssertEqual(locationNotifier.requestAuthorizationCounter, 1)
    }

    func test_init_shouldAddEntityStore() {
        XCTAssertEqual(dataStore.addEntityCounter, 1)
        XCTAssertEqual(dataStore.entitySpy, "Photo")
    }

    func test_init_shouldCreateStore() {
        XCTAssertEqual(dataStore.createStoreCounter, 1)
    }

    func test_isAutorized_returnFalse_whenDisabled() {
        setup {
            locationNotifier.injectedIsAuthorized = false
            locationNotifier.injectedIsEnabled = false
        }.test {
            XCTAssertFalse(sut.isAutorized(contentViewModel))
            XCTAssertFalse(contentViewModel.isAuthorized)
        }
    }


    func test_isAutorized_returnFalse_whenEnabled_butNotAuthorized() {
        setup {
            locationNotifier.injectedIsAuthorized = false
            locationNotifier.injectedIsEnabled = true
        }.test {
            XCTAssertFalse(sut.isAutorized(contentViewModel))
            XCTAssertFalse(contentViewModel.isAuthorized)
        }
    }

    func test_isAutorized_returnTrue_whenEnabled_andAuthorized() {
        setup {
            locationNotifier.injectedIsAuthorized = true
            locationNotifier.injectedIsEnabled = true
        }.test {
            XCTAssertTrue(sut.isAutorized(contentViewModel))
            XCTAssertTrue(contentViewModel.isAuthorized)
        }
    }

    func test_start_shouldNotStart_whenNotAccess() {
        setup {
            locationNotifier.injectedIsAuthorized = false
        }.test {
            sut.start(contentViewModel: contentViewModel)
        }.verify {
            XCTAssertEqual(locationNotifier.startMonitoringCounter, 0)
        }
    }

    func test_start_shouldSetAuthorizationStatus_whenNotAccess() {
        setup {
            locationNotifier.injectedIsAuthorized = false
        }.test {
            sut.start(contentViewModel: contentViewModel)
        }.verify {
            XCTAssertEqual(contentViewModel.isAuthorized, false)
        }
    }

    func test_start_shouldRequestLocation_whenNotEnabled() {
        test {
            sut.start(contentViewModel: contentViewModel)
        }.verify {
            XCTAssertEqual(contentViewModel.isAuthorized, false)
        }
    }

    func test_start_shouldStartMonitoring() {
        setup {
            locationNotifier.injectedIsAuthorized = true
            locationNotifier.injectedIsEnabled = true
        }.test {
            sut.start(contentViewModel: contentViewModel)
        }.verify {
            XCTAssertEqual(locationNotifier.startMonitoringCounter, 1)
        }
    }

    func test_start_shouldSetApiCallWhenValidlocation() {
        setup {
            locationNotifier.injectedIsAuthorized = true
            locationNotifier.injectedIsEnabled = true
        }.test {
            sut.start(contentViewModel: contentViewModel)
        }.verify {
            locationNotifier.onLocationChange?(Location(1, 1))
            locationNotifier.onLocationChange?(Location(1, 11))
            XCTAssertEqual(api.photoSearchCounter, 1)
        }
    }

    func test_start_shouldNotSetApiCallWhenNotValidlocation() {
        setup {
            locationNotifier.injectedIsAuthorized = true
            locationNotifier.injectedIsEnabled = true
        }.test {
            sut.start(contentViewModel: contentViewModel)
        }.verify {
            locationNotifier.onLocationChange?(Location(1, 10))
            locationNotifier.onLocationChange?(Location(1, 10.0001))
            XCTAssertEqual(api.photoSearchCounter, 0)
        }
    }

    func test_start_shouldSavePhoto() {
        guard let data = photoSearchSample.data(using: .utf8),
            let flickr = Flickr.build(from: data)
            else { return XCTFail("data is necessary for this test")}
        setup {
            locationNotifier.injectedIsAuthorized = true
            locationNotifier.injectedIsEnabled = true
            api.injectedCompletionPhotoSerch = .success(flickr)
        }.test {
            sut.start(contentViewModel: contentViewModel)
        }.verify {
            locationNotifier.onLocationChange?(Location(1, 10))
            locationNotifier.onLocationChange?(Location(1, 11))
            XCTAssertEqual(dataStore.saveCounter, 1)
        }
    }


    func test_stop_shouldStopMonitoring() {
        test {
            sut.stop(contentViewModel)
        }.verify {
            XCTAssertEqual(locationNotifier.stopMonitoringCounter, 1)
        }
    }

    func test_reset_shouldCallREsetOnTheStore() {
        test {
            sut.reset(contentViewModel)
        }.verify {
            XCTAssertEqual(dataStore.cleanAllCounter, 1)
        }
    }

    func test_loadImage_shouldLoadImageWhenSuccessResponse() {
        var image: UIImage?
        var completion = 0
        setup {
            api.injectedCompletion = .success(UIImage())
        }.test {
            sut.loadImage(urlString: "http://apple.com") { resultImage in
                completion += 1
                image = resultImage
            }
        }.verify {
            XCTAssertEqual(completion, 1)
            XCTAssertEqual(api.imageCounter, 1)
            XCTAssertNotNil(image)
        }
    }

    func test_loadImage_shouldNotCallbackOnFailure() {
        var image: UIImage?
        var completion = 0
        test {
            sut.loadImage(urlString: "http://apple.com") { resultImage in
                completion += 1
                image = resultImage
            }
        }.verify {
            XCTAssertEqual(completion, 0)
            XCTAssertEqual(api.imageCounter, 1)
            XCTAssertNil(image)
        }
    }

    func test_fetchRequest_ShouldReturnCorrectRequest() {
        var fetchRequest: FetchRequest<MOPhoto>?
        test {
            fetchRequest = sut.fetchRequest()
        }.verify {
            XCTAssertNotNil(fetchRequest)
        }
    }
}
