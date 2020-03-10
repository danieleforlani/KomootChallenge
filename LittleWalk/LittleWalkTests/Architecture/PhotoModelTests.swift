//
//  PhotoModelTests.swift
//  LittleWalkTests
//
//  Created by Scheggia on 10/03/2020.
//  Copyright © 2020 Flowprocess. All rights reserved.
//

@testable import LittleWalk
import XCTest
import CoreData
import AppFoundation

class PhotoModelTests: XCTestCase {

    var sut = Photo(id: "identifier",
                    owner: "owner",
                    secret: "secret",
                    server: "server",
                    farm: 12,
                    title: "title")

    func test_build_shouldCreateObjectCorectly() {
        guard let data = photoSearchSample.data(using: .utf8)
            else { return XCTFail("Data need to exist to make this test work") }
        var flickr: Flickr?
        test {
            flickr = Flickr.build(from: data)
        }.verify {
            XCTAssertEqual(flickr?.stat, "ok")
            XCTAssertEqual(flickr?.photos.page, 1)
            XCTAssertEqual(flickr?.photos.pages, 42)
            XCTAssertEqual(flickr?.photos.perpage, 1)
            XCTAssertEqual(flickr?.photos.total, "42")
            XCTAssertEqual(flickr?.photos.photo.count, 1)
            XCTAssertEqual(flickr?.photos.photo.first?.id, "38122644605")
            XCTAssertEqual(flickr?.photos.photo.first?.owner, "87674798@N06")
            XCTAssertEqual(flickr?.photos.photo.first?.server, "4585")
            XCTAssertEqual(flickr?.photos.photo.first?.secret, "17e11b392a")
        }
    }

    func test_managedObject_shouldReturnCorrectObject() {
        var context: NSManagedObjectContext!
        let dataStore = DataStore(store: storeName)
        var moObject: MOPhoto?

        setup {
            dataStore.addEntity(Photo.self, attributes: [("id", .stringAttributeType),
                                                         ("owner", .stringAttributeType),
                                                         ("secret", .stringAttributeType),
                                                         ("server", .stringAttributeType),
                                                         ("title", .stringAttributeType),
                                                         ("farm", .integer16AttributeType),
                                                         ("time", .doubleAttributeType),
                                                         ("url", .stringAttributeType)])
            dataStore.createStore()
            context = dataStore.container.container?.viewContext
        }.test {
            moObject = sut.managedObject(context) as? MOPhoto
        }.verify {
            XCTAssertEqual(sut.owner, moObject?.owner)
            XCTAssertEqual(sut.secret, moObject?.secret)
            XCTAssertEqual(sut.server, moObject?.server)
            XCTAssertEqual(sut.farm, moObject?.farm?.intValue)
            XCTAssertEqual(sut.title, moObject?.title)
            XCTAssertNotNil(moObject?.time?.intValue)
            XCTAssertEqual(moObject?.url, "https://farm12.staticflickr.com/server/identifier_secret.jpg")
        }
    }

    func test_idValue_ShouldReturnCorrectValue() {
        XCTAssertNotNil(sut.idValue)    
    }

    func test_idKey_ShouldReturnCorrectValue() {
        XCTAssertEqual(sut.idKey, "id")
    }
}
