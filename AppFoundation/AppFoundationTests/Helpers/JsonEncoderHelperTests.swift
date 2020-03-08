//
//  JsonEncoderHelperTests.swift
//  AppFoundationTests
//
//  Created by Scheggia on 28/02/2020.
//  Copyright © 2020 Attio. All rights reserved.
//

import XCTest
@testable import AppFoundation
import CoreData

// DO create a Mock file this goes there

struct User: Codable {
    var name: String
    var surname: String
    var age = 42
}
extension User: Hashable { }
extension User: MOTransformable {
    func managedObject(_ context: NSManagedObjectContext) -> NSManagedObject {
        let managedObject = UserMO(context: context)
        managedObject.name = name
        managedObject.surname = surname
        managedObject.age = NSNumber(value: age)

        return managedObject
    }

    var idKey: String {
        "name"
    }
    var idValue: String {
        name
    }
}

@objc(UserMO)
class UserMO: NSManagedObject { }
extension UserMO {
    @NSManaged public var name: String?
    @NSManaged public var surname: String?
    @NSManaged public var age: NSNumber?
}

struct Server: Codable {
    var name: String
    var ip: String
}
extension Server: Hashable { }
extension Server: MOTransformable {
    func managedObject(_ context: NSManagedObjectContext) -> NSManagedObject {
        let managedObject = ServerMO(context: context)
        managedObject.name = name
        managedObject.ip = ip

        return managedObject
    }

    var idKey: String {
        "name"
    }
    var idValue: String {
        name
    }
}

class ServerMO: NSManagedObject { }
extension ServerMO {
    @NSManaged public var name: String?
    @NSManaged public var ip: String?
}

class JsonEncoderHelperTests: XCTestCase {

    func test_encode_shouldEncodeCorrectly() {
        var encoded: Data!
        var decodedUser: User?
        let user = User(name: "Daniele",
                        surname: "Forlani",
                        age: 42)
        test {
            encoded = JSONEncoder.encode(user)
        }.verify {
            decodedUser = JSONDecoder.decode(User.self, from: encoded)
            XCTAssertNotNil(encoded)
            XCTAssertEqual(decodedUser, user)
        }
    }

    func test_decode_shouldDencodeCorrectly() {
        let user = User(name: "Daniele",
                        surname: "Forlani",
                        age: 42)
        var useerDecoded: User?
        var encoded: Data!

        setup {
            encoded = JSONEncoder.encode(user)
        }.test {
            useerDecoded = JSONDecoder.decode(User.self, from: encoded)
        }.verify {
            XCTAssertEqual(useerDecoded, user)
        }
    }

    func test_dencode_shouldReturnNilWhenDecodeFail() {
        var useerDecoded: User?

        test {
            useerDecoded = JSONDecoder.decode(User.self, from: "encoded".data(using: .utf8)!)
        }.verify {
            XCTAssertNil(useerDecoded)
        }
    }

}
