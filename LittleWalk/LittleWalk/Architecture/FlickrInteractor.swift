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
    func start(contentViewModel: ContentViewModel)
    func stop(_ contentViewModel: ContentViewModel)
    func loadImage(urlString: String?, completion: @escaping (UIImage) -> Void)
    func isAutorized(_ contentViewModel: ContentViewModel) -> Bool
    func fetchRequest() -> FetchRequest<MOPhoto>
    func reset(_ contentViewModel: ContentViewModel)
}

enum FeatureStatus {
    case active
    case inactive
    case cleaned
}

class FlickrInteractor {
    private var locationNotifier: LocationNotifierType
    private var container: InjectionContainer
    private var dataStore: DataStoreType & PersistentStoreType
    private var flickrAPI: FlickrAPIType
    private var previousLocation: Location?
    private var dispatchable: DispatchableType

    init(locationNotifier: LocationNotifierType,
         dataStore: DataStoreType & PersistentStoreType = DataStore(store: storeName),
         api: FlickrAPIType,
         container: InjectionContainer, dispatchable: DispatchableType = Dispatchable()) {
        self.dataStore = dataStore
        self.flickrAPI = api
        self.container = container
        self.locationNotifier = locationNotifier
        self.dispatchable = dispatchable

        container.register(DataStoreType.self) {
            self.dataStore
        }
        locationNotifier.requestAuthorization()
        dataStore.addEntity(Photo.self, attributes: [("id", .stringAttributeType),
                                                     ("owner", .stringAttributeType),
                                                     ("secret", .stringAttributeType),
                                                     ("server", .stringAttributeType),
                                                     ("title", .stringAttributeType),
                                                     ("farm", .integer16AttributeType),
                                                     ("time", .doubleAttributeType),
                                                     ("url", .stringAttributeType)])
        dataStore.createStore()
    }
}

extension FlickrInteractor: FlickrInteractorType {

    func isAutorized(_ contentViewModel: ContentViewModel) -> Bool {
        guard locationNotifier.isEnabled else {
            contentViewModel.isAuthorized = false
            return false
        }
        guard locationNotifier.isAuthorized else {
            locationNotifier.requestAuthorization()
            return false
        }
        contentViewModel.isAuthorized = true
        return true
    }

    func start(contentViewModel: ContentViewModel) {
        let oneHundredMeters = 0.1

        guard isAutorized(contentViewModel), contentViewModel.status != .active else {
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
        contentViewModel.status = .active
    }

    private func searchPhotos(on location: Location) {
        flickrAPI.photoSearch(location: location) { result in
            switch result {
            case .success(let flickr):
                let random = Int.random(in: 0..<flickr.photos.photo.count)
                if flickr.photos.photo.first != nil {
                    self.dataStore.save(flickr.photos.photo[random])
                }
            case .failure(let error):
                print("Error in calling the APIs of flicker :\(error)")
            }
        }
    }

    func stop(_ contentViewModel: ContentViewModel) {
        locationNotifier.stopMonitoring()
        contentViewModel.status = .inactive
    }

    func reset(_ contentViewModel: ContentViewModel) {
        dataStore.cleanAll()
        contentViewModel.status = .cleaned
    }

    func loadImage(urlString: String?, completion: @escaping (UIImage) -> Void) {
        guard let imageURL = urlString,
              let url = URL(string: imageURL)
            else { return }
        flickrAPI.image(url: url) { result in
            switch result {
            case .success(let image):
                self.dispatchable.mainAsync {
                   completion(image)
                }
            case .failure(let error):
                print("Error downloading the image \(error)")
            }

        }
    }

    func fetchRequest() -> FetchRequest<MOPhoto> {
        FetchRequest(fetchRequest:
            dataStore.fetch(Photo.self,
                            entityType: MOPhoto.self,
                            descriptors: [NSSortDescriptor(key: "time",
                                                           ascending: false)],
                            predicateString: nil))
    }
}

import SwiftUI

class ContentViewModel: ObservableObject {
    var noAuthoriationMessage = "Please enable the location to enjoy your Little Walk."
    @Published var isAuthorized = false
    @Published var status: FeatureStatus = .inactive
}
