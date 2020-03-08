//
//  FlickrInteractor.swift
//  LittleWalk
//
//  Created by Scheggia on 06/03/2020.
//  Copyright © 2020 Flowprocess. All rights reserved.
//

import AppFoundation
import CoreData

protocol FlickrInteractorType {
    func start(authorizationViewModel: AuthorizationViewModel)
    func stop()
}

class FlickrInteractor {
    private var locationNotifier: LocationNotifierType
    private var container: InjectionContainer
    private var dataStore: DataStoreType & PersistentStoreType
    private var flickrAPI: FlickrAPIType
    private var previousLocation: Location?

    init(locationNotifier: LocationNotifierType,
         dataStore: DataStoreType & PersistentStoreType = DataStore(store: storeName),
         api: FlickrAPIType,
         container: InjectionContainer) {
        self.dataStore = dataStore
        self.flickrAPI = api
        self.container = container
        self.locationNotifier = locationNotifier

        container.register(DataStoreType.self) {
            self.dataStore
        }
        locationNotifier.requestAuthorization()
        dataStore.addEntity(Photo.self, attributes: [("id", .stringAttributeType),
                                                     ("owner", .stringAttributeType),
                                                     ("secret", .stringAttributeType),
                                                     ("server", .stringAttributeType),
                                                     ("title", .stringAttributeType),
                                                     ("farm", .integer16AttributeType)])
        dataStore.createStore()
    }
}

extension FlickrInteractor: FlickrInteractorType {

    func isAutozed(_ authorizationViewModel: AuthorizationViewModel) -> Bool {
        guard locationNotifier.isEnabled else {
            authorizationViewModel.isAuthorized = false
            return false
        }
        authorizationViewModel.isAuthorized = true
        guard locationNotifier.isAuthorized else {
            locationNotifier.requestAuthorization()
            return false
        }
        return true
    }

    func start(authorizationViewModel: AuthorizationViewModel) {
        let oneHundredMeters = 0.1

        guard isAutozed(authorizationViewModel) else {
            return
        }
        locationNotifier.startMonitoring() { location in
            guard let previousLocation = self.previousLocation else {
                self.previousLocation = location
                return
            }
            guard previousLocation.distance(from: location) > oneHundredMeters else {
                return
            }
            self.previousLocation = location
            self.searchPhotos(on: location)
        }
    }

    private func searchPhotos(on location: Location) {
        flickrAPI.photoSearch(location: location) { result in
            switch result {
            case .success(let flickr):
                if let photo = flickr.photos.photo.first {
                    self.dataStore.save(photo)
                }
            case .failure(let error):
                print("Error in calling the APIs of flicker :\(error)")
            }
        }
    }

    func stop() {
        locationNotifier.stopMonitoring()
    }
}

import SwiftUI

class AuthorizationViewModel: ObservableObject {
    var noAuthoriationMessage = "Please enable the location to enjoy your Little Walk."
    @Published var isAuthorized = false
}
