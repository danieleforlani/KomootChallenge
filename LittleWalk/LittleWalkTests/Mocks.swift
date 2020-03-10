//
//  Mocks.swift
//  LittleWalkTests
//
//  Created by Scheggia on 10/03/2020.
//  Copyright © 2020 Flowprocess. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
@testable import LittleWalk
import AppFoundation
import UIKit

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

class MockDataStore: DataStoreType {
    var cleanAllCounter = 0
    func cleanAll() {
        cleanAllCounter += 1
    }

    required init(store: String, container: PersistentContainerType) { }
    var createStoreCounter = 0
    var addEntityCounter = 0
    var entitySpy = ""
    func createStore() {
        createStoreCounter += 1
    }
    var saveCounter = 0
    func save<T: MOTransformable>(_ object: T) { saveCounter += 1}
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
        imageCounter += 1
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

class MockDispatchable: DispatchableType {
    func mainAsync(_ block: @escaping () -> Void) {
        block()
    }

    func mainAsync(after delay: Int, _ block: @escaping () -> Void) {
        block()
    }


}
