//
//  JsonEncoderHelperTests.swift
//  AppFoundationTests
//
//  Created by Scheggia on 28/02/2020.
//  Copyright © 2020 Attio. All rights reserved.
//

import XCTest

struct User: Codable {
    var name: String
    var surname: String
    var age = 42
}
extension User: Hashable {

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
