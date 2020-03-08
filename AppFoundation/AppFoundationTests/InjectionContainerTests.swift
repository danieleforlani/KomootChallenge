//
//  InjectionContainerTests.swift
//  AppFoundationTests
//
//  Created by Scheggia on 02/03/2020.
//  Copyright © 2020 Attio. All rights reserved.
//
@testable import AppFoundation
import XCTest

class InjectionContainerTests: XCTestCase {

    var sut: InjectionContainer!

    override func setUp() {
        super.setUp()
        sut = InjectionContainer()
    }

    func test_register_shouldSaveTheBlock() {
        test {
            sut.register(TestClass.self) {
                TestClass( "one")
            }
        }.verify {
            XCTAssertNotNil(sut.resolve(TestClass.self))
            XCTAssertEqual(sut.container.count, 1)
        }
    }

    func test_register_shouldReplaceTheBlock_whenAlreadySaved() {
        let testClass = TestClass("one")
        setup {
            sut.register(TestClass.self) {
                 TestClass("two")
            }
        }.test {
            sut.register(TestClass.self) {
                testClass
            }
        }.verify {
            XCTAssertEqual(sut.resolve(TestClass.self), testClass)
        }
    }

    func test_resolve_shouldReturnNil_whenNoProtocolregistred() {
        var testClass: TestClass?
        test {
            testClass = sut.resolve(TestClass.self)
        }.verify {
            XCTAssertNil(testClass)
        }
    }

    func test_resolve_shouldRunTheBlock() {
        var testClass: TestClass?
        setup {
            sut.register(TestClass.self) {
                 TestClass("one")
            }
        }.test {
            testClass = sut.resolve(TestClass.self)
        }.verify {
            XCTAssertNotNil(test)
            XCTAssertEqual(testClass?.identifier, "one")
        }
    }
}

protocol TestType {}
class TestClass: TestType {
    let identifier: String

    init(_ identifier: String) {
        self.identifier = identifier
    }
}
extension TestClass: Hashable {
    static func == (lhs: TestClass, rhs: TestClass) -> Bool {
        lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        self.identifier.hash(into: &hasher)
    }
}
