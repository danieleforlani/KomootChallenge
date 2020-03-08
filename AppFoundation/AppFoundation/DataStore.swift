//
//  DataStore.swift
//  AppFoundation
//
//  Created by Scheggia on 02/03/2020.
//  Copyright © 2020 Attio. All rights reserved.
//

import SwiftUI
import CoreData

public protocol DataStoreType {
    init(store: String, container: PersistentContainerType)
    func createStore()
    func save<T: MOTransformable>(_ object: T)
    func delete<T: MOTransformable>(_ object: T)
    func fetch<T: MOTransformable, G: NSManagedObject>(_ protocolType: T.Type,
                                                       entityType: G.Type,
                                                       descriptors: [NSSortDescriptor]?,
                                                       predicateString: String?) -> NSFetchRequest<G>
}

public class DataStore: DataStoreType {

    var store: String
    var entities: [String: [String]] = [:]
    var relations: [String: String] = [:]

    var container: PersistentContainerType = PersistentContainer()
    var model: NSManagedObjectModel? {
        get {
            container.model
        }
        set {
            container.model = newValue
        }
    }

    public required init(store: String, container: PersistentContainerType = PersistentContainer()) {
        self.store = store
        self.container = container
        self.container.model = container.model(store: store)
    }

    public func createStore() {
        container.createStore(name: store)
    }

    public func save<T: MOTransformable>(_ object: T) {
        container.onBackground { context in
            self.container.save(object, context)
            self.container.commit(context)
        }
    }

    public func delete<T: MOTransformable>(_ object: T) {
        container.onBackground { context in
            self.container.delete(object, context)
            self.container.commit(context)
        }
    }

    public func cleanAll() {
        container.onBackground { context in
            self.container.delete(context)
            self.container.commit(context)
        }
    }

    public func fetch<T: MOTransformable, G: NSManagedObject>(_ protocolType: T.Type,
                                                              entityType: G.Type,
                                                              descriptors: [NSSortDescriptor]? = nil,
                                                              predicateString: String? = nil)
        -> NSFetchRequest<G> {
            let fetchRequest: NSFetchRequest<G> = NSFetchRequest(entityName: "\(protocolType)")
            fetchRequest.predicate = predicateString == nil
                ? NSPredicate(value: true)
                : NSPredicate(format: predicateString!)
            fetchRequest.sortDescriptors = descriptors
            return fetchRequest
    }
}

public protocol MOTransformable {
    func managedObject(_ context: NSManagedObjectContext) -> NSManagedObject
    var idKey: String { get }
    var idValue: String { get }
}
