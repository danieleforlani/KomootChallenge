//
//  FlickrAPITests.swift
//  LittleWalkTests
//
//  Created by Scheggia on 06/03/2020.
//  Copyright © 2020 Flowprocess. All rights reserved.
//

@testable import LittleWalk
import AppFoundation
import XCTest

class FlickrAPITests: XCTestCase {

    var sut: FlickrAPI!

    var networking: MockNetworking!
    var composer = URLComposer()
    var diContainer = InjectionContainer()

    override func setUp() {
        super.setUp()
        self.networking = MockNetworking(URLSession.shared, dispatchable: Dispatchable())
        diContainer.register(NetworkingType.self) {
            self.networking
        }
        sut = FlickrAPI(networking: networking)
    }

    func test_photoSearch_shouldCallNetworking_withCorrectResult() {
        let expect = expectation(description: "completion called")
        var flickr: Flickr?
        setup {
            guard let data = photoSearchSample.data(using: .utf8)
                else { return XCTFail("The data need to exist to display the values")}
            networking.injectedModel = Flickr.build(from: data)
        }.test {
            sut.photoSearch(location: Location(11, 12)) { (result: Result<Flickr, ApiError>) in
                flickr = result.result
                expect.fulfill()
            }
            wait(for: [expect], timeout: 1.0)
        }.verify {
            let url = self.composer.photoSearch(location: Location(11, 12))
            XCTAssertEqual(self.networking.loaderCounter, 1)
            XCTAssertEqual(self.networking.requestSpy?.httpMethod, HTTPMethod.GET.rawValue)
            XCTAssertEqual(self.networking.requestSpy?.url?.absoluteString, url?.absoluteString)
            XCTAssertEqual(flickr?.photos.photo.first?.id, "38122644605")
            XCTAssertEqual(flickr?.photos.photo.first?.farm, 5)
            XCTAssertEqual(flickr?.photos.photo.first?.owner, "87674798@N06")
            XCTAssertEqual(flickr?.photos.photo.first?.secret, "17e11b392a")
            XCTAssertEqual(flickr?.photos.photo.first?.title, "From Skopje to Ohrid, Republic of Macedonia (馬其頓共和國)")
            XCTAssertEqual(flickr?.photos.photo.first?.server, "4585")
        }
    }

    func test_photoSearch_shouldFail_whenErrorOccour() {
        let expect = expectation(description: "completion called")
        var error: ApiError?
        setup {
            networking.injectedError = ApiError(code: 401, message: "force error")
        }.test {
            sut.photoSearch(location: Location(11, 12)) { (result: Result<Flickr, ApiError>) in
                error = result.error
                expect.fulfill()
            }
            wait(for: [expect], timeout: 1.0)
        }.verify {
            XCTAssertEqual(self.networking.loaderCounter, 1)
            XCTAssertEqual(error?.code, 401)
            XCTAssertEqual(error?.message, "force error")
        }
    }

    func test_image_shouldCallNetworking_withCorrectResult() {
        let expect = expectation(description: "completion called")
        var image: UIImage?
        setup {
            guard let data = photoSearchSample.data(using: .utf8)
                else { return XCTFail("The data need to exist to display the values")}
            networking.injected = data
        }.test {
            sut.image(url: URL(string: "http://apple.com")!) { (result: Result<UIImage, ApiError>) in
                image = result.result
                expect.fulfill()
            }
            wait(for: [expect], timeout: 1.0)
        }.verify {
            XCTAssertEqual(self.networking.loaderCounter, 1)
            XCTAssertNotNil(image)
        }
    }

    func test_image_shouldFail_whenErrorOccour() {
        let expect = expectation(description: "completion called")
        var error: ApiError?
        setup {
            networking.injectedError = ApiError(code: 401, message: "force error")
        }.test {
            sut.image(url: URL(string: "http://apple.com")!) { (result: Result<UIImage, ApiError>) in
                error = result.error
                expect.fulfill()
            }
            wait(for: [expect], timeout: 1.0)
        }.verify {
            XCTAssertEqual(self.networking.loaderCounter, 1)
            XCTAssertEqual(error?.code, 3000)
            XCTAssertEqual(error?.message, "Something went wrong, please retry later.")
        }
    }
}

class URLComposerTests: XCTestCase {

    var sut = URLComposer()

    func test_photoSearch_shouldReturnCorrectURL() {
        XCTAssertEqual(sut.photoSearch(location: Location( 1, 2))?.absoluteString, "https://api.flickr.com/services/rest?method=flickr.photos.search&api_key=2da49d8fb63c9dc26bc8d5006be413ca&per_page=20&lat=1.0&lon=2.0&format=json&nojsoncallback=1&radius=0.1")
    }

    func test_photoURL_shouldReturnCorrectURL() {
        XCTAssertEqual(sut.photoURL(farm: "1", server: "2", id: "3", secret: "5"), "https://farm1.staticflickr.com/2/3_5.jpg")
    }
}

class MockNetworking: NetworkingType {

    var session: URLSession
    var dispatchable: DispatchableType

    required init(_ session: URLSession, dispatchable: DispatchableType) {
        self.session = session
        self.dispatchable = dispatchable
    }

    var injected: Data?
    func load(_ request: URLRequest, completion: @escaping (Result<Data, ApiError>) -> Void) -> URLSessionDataTask? {
        loaderCounter += 1
        if let injected = injected {
            completion(.success(injected))
        } else {
            completion(.failure(unknowError))
        }
        return MockDataTask()
    }

    var loaderCounter = 0
    var requestSpy: URLRequest?
    var injectedError: ApiError?
    var injectedModel: Any?
    func load<T>(_ request: URLRequest, completion: @escaping (Result<T, ApiError>) -> Void) -> URLSessionDataTask? where T: DataBuildable {
        loaderCounter += 1
        requestSpy = request
        if let error = injectedError {
            completion(.failure(error))
        } else if let model = injectedModel as? T {
            completion(.success(model))
        }
        return MockDataTask()
    }

    var cleanCacheCounter = 0
    func cleanCache(_ cache: CacheType) {
        cleanCacheCounter += 1
    }
}

class MockDataTask: URLSessionDataTask {
    var resumeCounter = 0
    override func resume() {
        resumeCounter += 1
    }

    override init() {
    }
}
