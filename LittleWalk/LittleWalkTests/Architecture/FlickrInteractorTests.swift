//
//  FlickrInteractorTests.swift
//  LittleWalkTests
//
//  Created by Scheggia on 06/03/2020.
//  Copyright © 2020 Flowprocess. All rights reserved.
//

@testable import LittleWalk
import AppFoundation
import XCTest

class FlickrInteractorTests: XCTestCase {

    var sut: FlickrInteractor!
    var locationNotifier = MockLocationNotifier()
    var persistentContainer = MockPersistentContainer()
    var dataStore: MockDataStore!
    var container = InjectionContainer()
    var authorizationViewModel = AuthorizationViewModel()
    var api = MockFlickrAPI()

    override func setUp() {
        super.setUp()
        dataStore = MockDataStore(store: storeName,
                                  container: persistentContainer)
        sut = FlickrInteractor(locationNotifier: locationNotifier,
                               dataStore: dataStore,
                               api: api,
                               container: container)
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

    func test_start_shouldNotStart_whenNotAccess() {
        setup {
            locationNotifier.injectedIsAuthorized = false
        }.test {
            sut.start(authorizationViewModel: authorizationViewModel)
        }.verify {
            XCTAssertEqual(locationNotifier.startMonitoringCounter, 0)
        }
    }

    func test_start_shouldSetAuthorizationStatus_whenNotAccess() {
        setup {
            locationNotifier.injectedIsAuthorized = false
        }.test {
            sut.start(authorizationViewModel: authorizationViewModel)
        }.verify {
            XCTAssertEqual(authorizationViewModel.isAuthorized, false)
        }
    }

    func test_start_shouldRequestLocation_whenNotEnabled() {
        test {
            sut.start(authorizationViewModel: authorizationViewModel)
        }.verify {
            XCTAssertEqual(authorizationViewModel.isAuthorized, false)
        }
    }

    func test_start_shouldStartMonitoring() {
        setup {
            locationNotifier.injectedIsAuthorized = true
            locationNotifier.injectedIsEnabled = true
        }.test {
            sut.start(authorizationViewModel: authorizationViewModel)
        }.verify {
            XCTAssertEqual(locationNotifier.startMonitoringCounter, 1)
        }
    }

    func test_start_shouldSetApiCallWhenValidlocation() {
        setup {
            locationNotifier.injectedIsAuthorized = true
            locationNotifier.injectedIsEnabled = true
        }.test {
            sut.start(authorizationViewModel: authorizationViewModel)
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
            sut.start(authorizationViewModel: authorizationViewModel)
        }.verify {
            locationNotifier.onLocationChange?(Location(1, 10))
            locationNotifier.onLocationChange?(Location(1, 10.001))
            XCTAssertEqual(api.photoSearchCounter, 1)
        }
    }


    func test_stop_shouldStopMonitoring() {
        test {
            sut.stop()
        }.verify {
            XCTAssertEqual(locationNotifier.stopMonitoringCounter, 1)
        }
    }


}

class MockLocationNotifier: NSObject, LocationNotifierType {

    var injectedIsEnabled = false
    var isEnabled: Bool {
        injectedIsEnabled
    }

    var startMonitoringCounter = 0
    var onLocationChange: ((Location) -> Void)?
    func startMonitoring(onLocationChange: @escaping (Location) -> Void) {
        startMonitoringCounter += 1
        self.onLocationChange = onLocationChange
    }


    var injectedIsAuthorized = false
    var isAuthorized: Bool {
        injectedIsAuthorized
    }

    var stopMonitoringCounter = 0
    func stopMonitoring() {
        stopMonitoringCounter += 1
    }

    var requestAuthorizationCounter = 0
    func requestAuthorization() {
        requestAuthorizationCounter += 1
    }
}

import CoreData

class MockDataStore: DataStoreType {
    required init(store: String, container: PersistentContainerType) { }
    var createStoreCounter = 0
    var addEntityCounter = 0
    var entitySpy = ""
    func createStore() {
        createStoreCounter += 1
    }
    func save<T: MOTransformable>(_ object: T) { }
    func delete<T: MOTransformable>(_ object: T) { }
    func fetch<T: MOTransformable, G: NSManagedObject>(_ protocolType: T.Type,
                                                       entityType: G.Type,
                                                       descriptors: [NSSortDescriptor]?,
                                                       predicateString: String?) -> NSFetchRequest<G> {

        return NSFetchRequest(entityName: "Flickr")
    }
}
extension MockDataStore: PersistentStoreType {
    func addEntity<T>(_ entityType: T.Type, attributes: [(String, NSAttributeType)]) where T : Decodable, T : Encodable {
        addEntityCounter += 1
        entitySpy = "\(entityType)"
    }

    func addRelations<T, G>(_ lhsEntityType: T.Type, _ rhsEntityType: G.Type, relation: DataStoreRelation) where T : Decodable, T : Encodable, G : Decodable, G : Encodable {
    }


}

class MockPersistentContainer: NSObject, PersistentContainerType {

    var model: NSManagedObjectModel?

    var container: NSPersistentContainer?

    func model(store: String) -> NSManagedObjectModel? { return nil }

    func createStore(name: String) { }

    func save<T>(_ object: T, _ context: ContextType) where T : MOTransformable { }

    func delete<T>(_ object: T, _ context: ContextType) where T : MOTransformable { }

    func delete(_ context: ContextType) { }

    func commit() { }

    func commit(_ context: ContextType) { }

    func onBackground(_ completion: @escaping (NSManagedObjectContext) -> Void) { }

    func fetch<T>(type: T.Type, _ context: ContextType, predicateString: String) -> [NSManagedObject]? where T : MOTransformable {
        return nil
    }
}

class MockFlickrAPI: FlickrAPIType {

    var networking: NetworkingType = MockNetworking(URLSession.shared,
                                    dispatchable: Dispatchable())

    var injectedCompletion: Result<UIImage, ApiError> = .failure(unknowError)
    var imageCounter = 0
    func image(url: URL, completion: @escaping (Result<UIImage, ApiError>) -> Void) {
        imageCounter += 0
        completion(injectedCompletion)
    }

    var injectedCompletionPhotoSerch: Result<Flickr, ApiError> = .failure(unknowError)
    var photoSearchCounter = 0
    func photoSearch(location: Location,
                     completion: @escaping (Result<Flickr, ApiError>) -> Void) {
        photoSearchCounter += 1
        completion(injectedCompletionPhotoSerch)
    }
}
