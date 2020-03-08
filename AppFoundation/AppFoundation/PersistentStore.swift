//
//  PersistentStore.swift
//  AppFoundation
//
//  Created by Scheggia on 02/03/2020.
//  Copyright © 2020 Attio. All rights reserved.
//

import CoreData

public protocol PersistentStoreType {

    func addEntity<T: Codable>(_ entityType: T.Type,
                               attributes: [(String, NSAttributeType)])
    func addRelations<T: Codable, G: Codable>(_ lhsEntityType: T.Type,
                                              _ rhsEntityType: G.Type,
                                              relation: DataStoreRelation)
}

extension DataStore: PersistentStoreType {

    public func addEntity<T: Codable>(_ entityType: T.Type,
                                      attributes: [(String, NSAttributeType)]) {
        let entity = NSEntityDescription()
        entity.name = "\(T.self)"
        let entityAttributes: [NSAttributeDescription] = attributes.map {
            let attribute = NSAttributeDescription()
            attribute.name = $0.0
            attribute.attributeType = $0.1
            return attribute
        }
        entity.managedObjectClassName = "\(T.self)MO"
        entity.properties = entityAttributes
        model = save(entities: [entity], in: model?.copy(with: nil) as? NSManagedObjectModel)
    }

    private func save(entities: [NSEntityDescription], in model: NSManagedObjectModel?) -> NSManagedObjectModel? {
        let entitiesNames = entities.map { $0.name }
        var existingEntities = model?.entities
            .compactMap { $0.copy(with: nil) as? NSEntityDescription}
            .filter { !entitiesNames.contains($0.name)} ?? []
        existingEntities.append(contentsOf: entities)
        model?.entities = existingEntities
        return model
    }

    public func addRelations<T: Codable, G: Codable>(_ lhsEntityType: T.Type,
                                                     _ rhsEntityType: G.Type,
                                                     relation: DataStoreRelation) {
        var entities = model?.entities
        guard  let lhsEntity = model?.entitiesByName["\(lhsEntityType)"]?.copy() as? NSEntityDescription,
        let rhsEntity = model?.entitiesByName["\(rhsEntityType)"]?.copy() as? NSEntityDescription
            else {
                return
        }
        entities = entities?.compactMap { $0.name != "\(lhsEntityType)" && $0.name != "\(rhsEntityType)" ? $0 : nil }
        let lhsRelation = NSRelationshipDescription()
        let rhsRelation = NSRelationshipDescription()
        lhsRelation.name = relation.name
        lhsRelation.minCount = relation.minCount
        lhsRelation.maxCount  = relation.maxCount
        lhsRelation.deleteRule = relation.deleteRule
        lhsRelation.destinationEntity = rhsEntity
        lhsRelation.inverseRelationship = rhsRelation

        rhsRelation.name = relation.inverseName
        rhsRelation.minCount = 1
        rhsRelation.maxCount = relation.inverseCount
        rhsRelation.destinationEntity = lhsEntity
        rhsRelation.inverseRelationship = lhsRelation

        lhsEntity.properties.append(lhsRelation)
        rhsEntity.properties.append(rhsRelation)

        model = save(entities: [lhsEntity, rhsEntity], in: model)
    }
}

public struct DataStoreRelation {
    let name: String
    let inverseName: String
    let minCount: Int
    let maxCount: Int
    let inverseCount: Int
    let deleteRule: NSDeleteRule
}

extension FileManager {
    var applicationDocumentsDirectory: URL {
        let urlsList = urls(for: .documentDirectory, in: .userDomainMask)
        return urlsList[urlsList.count-1]
    }
}

extension NSManagedObjectModel {
    static func model(bundle: Bundle, resource: String) -> NSManagedObjectModel? {
        guard let modelUrl = bundle.url(forResource: resource, withExtension: "momd"),
                  let managedObjectModel = NSManagedObjectModel(contentsOf: modelUrl) else {
            return nil
        }
        return managedObjectModel
    }
}
