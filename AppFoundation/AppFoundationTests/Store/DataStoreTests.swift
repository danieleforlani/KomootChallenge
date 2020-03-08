//
//  DataStoreTests.swift
//  AppFoundationTests
//
//  Created by Scheggia on 02/03/2020.
//  Copyright © 2020 Attio. All rights reserved.
//

import XCTest
@testable import AppFoundation
import CoreData
import SwiftUI

class DataStoreTests: XCTestCase {

    var sut: DataStore!
    var store: NSPersistentStore?
    let url = FileManager.default.applicationDocumentsDirectory.appendingPathComponent("DataStoreModel.sqlite")

    override func setUp() {
        super.setUp()
        sut = DataStore(store: "DataStoreModel", container: MainPersistentContainer())
        createStore()
        sut.cleanAll()
    }

    private func createStore() {
        sut.addEntity(User.self,
                      attributes: [("name", NSAttributeType.stringAttributeType),
                                   ("surname", NSAttributeType.stringAttributeType),
                                   ("age", NSAttributeType.integer16AttributeType)])

        sut.addEntity(Server.self,
                      attributes: [("name", NSAttributeType.stringAttributeType),
                                   ("ip", NSAttributeType.stringAttributeType)])

        let relation = DataStoreRelation(name: "server",
                                         inverseName: "owner",
                                         minCount: 0,
                                         maxCount: 0,
                                         inverseCount: 1,
                                         deleteRule: NSDeleteRule.cascadeDeleteRule)
        sut.addRelations(User.self, Server.self, relation: relation)

        sut.createStore()
    }

    func test_createStore_shouldCreateContainer() {
        XCTAssertNotNil(sut.container)
    }

    func test_save_shouldCreateManagedObject() {
        let user = User(name: "Daniele", surname: "Forlani", age: 42)

        test {
            sut.save(user)
        }.verify {
            let users = try? sut.container.container?.viewContext.fetch(sut.fetch(User.self, entityType: UserMO.self))
            XCTAssertEqual(users?.count, 1)
            XCTAssertEqual(users?.first?.name, "Daniele")
            XCTAssertEqual(users?.first?.surname, "Forlani")
            XCTAssertEqual(users?.first?.age?.intValue, 42)
        }
    }

    func test_save_shouldUpdateExistingManagedObject() {
        var user = User(name: "Daniele", surname: "Forlani", age: 42)
        setup {
            sut.save(user)
            user.age = 43
        }
        test {
            sut.save(user)
        }.verify {
            let users = try? sut.container.container?.viewContext.fetch(sut.fetch(User.self, entityType: UserMO.self))
            XCTAssertEqual(users?.first?.age?.intValue, 43)
        }
    }

    func test_delete_shouldDeleteCorrectManagedObject() {
        let userOne = User(name: "Daniele", surname: "Forlani", age: 42)
        let userTwo = User(name: "Forlani", surname: "Daniele", age: 42)
        setup {
            sut.save(userOne)
            sut.save(userTwo)
        }.test {
            sut.delete(userOne)
        }.verify {
            let users = try? sut.container.container?.viewContext.fetch(sut.fetch(User.self, entityType: UserMO.self))
            XCTAssertEqual(users?.count, 1)
            XCTAssertEqual(users?.first?.name, userTwo.name)
        }
    }

    func test_cleanAll_shouldDeleteEverything() {
        let userOne = User(name: "Daniele", surname: "Forlani", age: 42)
        let userTwo = User(name: "Forlani", surname: "Daniele", age: 42)
        setup {
            sut.save(userOne)
            sut.save(userTwo)
        }.test {
            sut.cleanAll()
        }.verify {
            let users = try? sut.container.container?.viewContext.fetch(sut.fetch(User.self, entityType: UserMO.self))
            XCTAssertEqual(users?.count, 0)
        }
    }

    func test_fetch_shouldReturnUsers() {
        let userOne = User(name: "Daniele", surname: "Forlani", age: 42)
        let userTwo = User(name: "Forlani", surname: "Daniele", age: 42)
        var users: [NSManagedObject]?
        setup {
            sut.save(userOne)
            sut.save(userTwo)
        }.test {
            users = try? sut.container.container?.viewContext.fetch(sut.fetch(User.self,
                                                                                  entityType: UserMO.self))
        }.verify {
            XCTAssertEqual(users?.count, 2)
        }
    }

    func test_fetch_shouldReturnUsers_inCorrectOrder() {
        let userOne = User(name: "Daniele", surname: "Forlani", age: 44)
        let userTwo = User(name: "Forlani", surname: "Daniele", age: 42)
        var users: [UserMO]?
        setup {
            sut.save(userOne)
            sut.save(userTwo)
        }.test {
            users = try? sut.container
                            .container?
                            .viewContext
                            .fetch(sut.fetch(User.self,
                                 entityType: UserMO.self,
                                 descriptors: [NSSortDescriptor(key: "age", ascending: true)]))
        }.verify {
            XCTAssertEqual(users?.first?.age, 42)
            XCTAssertEqual(users?.last?.age, 44)
        }
    }

    func test_fetch_shouldReturnUsers_filtered() {
        let userOne = User(name: "Daniele", surname: "Forlani", age: 40)
        let userTwo = User(name: "Forlani", surname: "Daniele", age: 42)
        var users: [UserMO]?
        setup {
            sut.save(userOne)
            sut.save(userTwo)
        }.test {
            users = try? sut.container.container?.viewContext.fetch(sut.fetch(User.self,
                                                                                  entityType: UserMO.self,
                                                                                  predicateString: "age = 42"))
        }.verify {
            XCTAssertEqual(users?.count, 1)
            XCTAssertEqual(users?.first?.age, 42)
        }
    }
}

class MainPersistentContainer: PersistentContainer {
    override func onBackground(_ completion: @escaping (NSManagedObjectContext) -> Void) {
        guard let context = container?.viewContext else { return }
        completion(context)
    }
}
