//
//  PersistentStoreTests.swift
//  AppFoundationTests
//
//  Created by Scheggia on 02/03/2020.
//  Copyright © 2020 Attio. All rights reserved.
//

import XCTest
@testable import AppFoundation
import CoreData

class PersistentStoreTests: XCTestCase {

    var sut: DataStore!

    override func setUp() {
        super.setUp()
        sut = DataStore(store: "DataStoreModel")
    }

    func test_createStore_shouldCreateStore() {
        test {
            sut.createStore()
        }.verify {
            XCTAssertEqual(sut.container
                                .container?
                                .persistentStoreCoordinator
                                .persistentStores
                                .count,
                           1)
        }
    }

    func test_addEntity_shouldaddEntityToTheStore() {
        test {
            sut.addEntity(User.self,
                          attributes: [("name", NSAttributeType.stringAttributeType),
                                       ("surname", NSAttributeType.stringAttributeType),
                                       ("age", NSAttributeType.integer16AttributeType)])
        }.verify {
            let entity = sut.model?.entities.first
            XCTAssertNotNil(entity)
            XCTAssertEqual(entity?.attributesByName.keys.count, 3)
            XCTAssertEqual(entity?.attributesByName.keys.contains("name"), true)
            XCTAssertEqual(entity?.attributesByName.keys.contains("age"), true)
            XCTAssertEqual(entity?.attributesByName.keys.contains("surname"), true)
        }
    }

    func test_addEntity_shouldAppendEntityToTheStore() {
        setup {
            sut.addEntity(User.self,
                          attributes: [("name", NSAttributeType.stringAttributeType),
                                       ("surname", NSAttributeType.stringAttributeType),
                                       ("age", NSAttributeType.integer16AttributeType)])

        }.test {
            sut.addEntity(Server.self,
                          attributes: [("name", NSAttributeType.stringAttributeType),
                                       ("ip", NSAttributeType.stringAttributeType)])
        }.verify {
            XCTAssertEqual(sut.model?.entities.count, 2)
            let entity = sut.model?.entities.last
            XCTAssertNotNil(entity)
            XCTAssertEqual(entity?.attributesByName.keys.count, 3)
            XCTAssertEqual(entity?.attributesByName.keys.contains("name"), true)
            XCTAssertEqual(entity?.attributesByName.keys.contains("age"), true)
            XCTAssertEqual(entity?.attributesByName.keys.contains("surname"), true)
        }
    }

    func test_addRelation_shouldCreateRelation() {
        let relation = DataStoreRelation(name: "server",
                                         inverseName: "owner",
                                         minCount: 0,
                                         maxCount: 0,
                                         inverseCount: 1,
                                         deleteRule: NSDeleteRule.cascadeDeleteRule)
        setup {
            sut.addEntity(User.self,
                          attributes: [("name", NSAttributeType.stringAttributeType),
                                       ("surname", NSAttributeType.stringAttributeType),
                                       ("age", NSAttributeType.integer16AttributeType)])

            sut.addEntity(Server.self,
                          attributes: [("name", NSAttributeType.stringAttributeType),
                                       ("ip", NSAttributeType.stringAttributeType)])

        }.test {
            sut.addRelations(User.self, Server.self, relation: relation)
        }.verify {
            XCTAssertEqual(sut.model?.entities.count, 2)
            let oneEntity = sut.model?.entities.last
            let twoEntity = sut.model?.entities.first
            XCTAssertEqual(oneEntity?.relationshipsByName.keys.count, 1)
            XCTAssertEqual(twoEntity?.relationshipsByName.keys.count, 1)
            XCTAssertEqual(oneEntity?.relationshipsByName.values.first?.name, relation.name)
            XCTAssertEqual(twoEntity?.relationshipsByName.values.first?.name, relation.inverseName)
            XCTAssertEqual(oneEntity?.relationshipsByName.values.first?.maxCount, 0)
            XCTAssertEqual(twoEntity?.relationshipsByName.values.first?.maxCount, 1)
            XCTAssertEqual(oneEntity?.relationshipsByName.values.first?.deleteRule, NSDeleteRule.cascadeDeleteRule)

        }
    }
}

class FileManagerTest: XCTestCase {
    func test_applicationDocumentsDirectory_shouldReturnCorrectUrl() {
        let sut = FileManager.default
        XCTAssertEqual(sut.applicationDocumentsDirectory.absoluteString.suffix(16), "/data/Documents/")
    }
}

class NSManagedObjectModelTest: XCTestCase {
    func test_model_shouldReturnCorrecModel() {
        var bundle: Bundle!
        var model: NSManagedObjectModel?

        setup {
            bundle = Bundle(for: DataStore.self)
        }.test {
            model = NSManagedObjectModel.model(bundle: bundle,
                                               resource: "DataStoreModel")
        }.verify {
            XCTAssertNotNil(model)
        }
    }

    func test_model_shouldReturnNil_WhenModelDoesNotExist() {
        var bundle: Bundle!
        var model: NSManagedObjectModel?

        setup {
            bundle = Bundle(for: NSManagedObjectModelTest.self)
        }.test {
            model = NSManagedObjectModel.model(bundle: bundle,
                                               resource: "NotExistingModel")
        }.verify {
            XCTAssertNil(model)
        }
    }
}
