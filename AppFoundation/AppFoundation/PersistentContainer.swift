//
//  PersistentContainer.swift
//  AppFoundation
//
//  Created by Scheggia on 08/03/2020.
//  Copyright © 2020 Attio. All rights reserved.
//

import Foundation
import CoreData

public protocol PersistentContainerType {
    var model: NSManagedObjectModel? { get set }
    var container: NSPersistentContainer? { get set }
    func model(store: String) -> NSManagedObjectModel?
    func createStore(name: String)
    func save<T: MOTransformable>(_ object: T, _ context: ContextType)
    func delete<T: MOTransformable>(_ object: T, _ context: ContextType)
    func delete(_ context: ContextType)
    func commit()
    func commit(_ context: ContextType)
    func onBackground(_ completion: @escaping (NSManagedObjectContext) -> Void)
    func fetch<T: MOTransformable>(type: T.Type,
                                   _ context: ContextType,
                                   predicateString: String) -> [NSManagedObject]?
}

public class PersistentContainer: PersistentContainerType {

    public var container: NSPersistentContainer?
    public var model: NSManagedObjectModel?

    public init() { }

    public func model(store: String) -> NSManagedObjectModel? {
        NSManagedObjectModel.model(bundle: Bundle(for: PersistentContainer.self),
                                   resource: store)
    }

    public func createStore(name: String) {
        guard let model = model else { return }
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.shouldDeleteInaccessibleFaults = true
        self.container = container
    }

    public func save<T: MOTransformable>(_ object: T, _ context: ContextType) {
        guard let context = context as? NSManagedObjectContext else { return }
        if let managedObject = fetch(type: type(of: object),
                                     context,
                                     predicateString: "\(object.idKey) = '\(object.idValue)'")?.first {
            let sourceManagedObject = object.managedObject(context)
            managedObject.entity.attributesByName.keys.forEach {
                managedObject.setValue(sourceManagedObject.value(forKey: $0), forKey: $0)
            }
        }
        _ = object.managedObject(context)
    }

    public func delete<T: MOTransformable>(_ object: T, _ context: ContextType) {
        guard let context = context as? NSManagedObjectContext,
            let managedObject = fetch(type: type(of: object),
                                      context,
                                      predicateString: "\(object.idKey) = '\(object.idValue)'")?.first
         else { return }
        context.delete(managedObject)
    }

    public func fetch<T: MOTransformable>(type: T.Type,
                                          _ context: ContextType,
                                          predicateString: String) -> [NSManagedObject]? {
        guard let context = context as? NSManagedObjectContext else { return nil }
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "\(type)")
        fetchRequest.predicate = NSPredicate(format: predicateString)
        let objects = try? context.fetch(fetchRequest)
        return objects
    }

    public func delete(_ context: ContextType) {
        guard let context = context as? NSManagedObjectContext else { return }
        context.reset()
        model?.entitiesByName.keys.forEach {
            _ = try? context.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: $0)))
        }

    }

    public func commit() {
        try? container?.viewContext.save()
    }

    public func commit(_ context: ContextType) {
        guard let context = context as? NSManagedObjectContext else { return }
        try? context.save()
    }

    public func onBackground(_ completion: @escaping (NSManagedObjectContext) -> Void) {
        container?.performBackgroundTask { context in
            completion(context)
        }
    }
}

public protocol ContextType {}
extension NSManagedObjectContext: ContextType {}
