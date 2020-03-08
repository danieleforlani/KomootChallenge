//
//  NetworkingTests.swift
//  MarksAndSpencerTests
//
//  Created by Daniele Forlani on 13/10/2018.
//  Copyright © 2018 Scheggia. All rights reserved.
//

import XCTest
@testable import AppFoundation

extension Data: DataBuildable {
    public static func build(from data: Data) -> Data? {
        return data
    }
}

class NetworkingTests: XCTestCase {

    var sut: Networking!
    var session = MockUrlSession()
    var imageUrl = URL(string: "http://www.johnlewis.com")!
    var cache = MockCache()

    override func setUp() {
        super.setUp()
        sut = Networking(session, dispatchable: MockDispatchable())
    }

    func test_load_shouldCallResume() {
        _ = sut.load(request) { (_: Result<MockDataBuildable, ApiError>) in }

        XCTAssertEqual(session.dataTask?.resumeCounter, 1)
    }

    var request: URLRequest {
        guard let url = URL(string: "http://www.johnlewis.com") else {
            fatalError()
        }
        return URLRequest(url: url)
    }

    func test_load_shouldCallCompletion_withSussess_whenSuccessfullCall() {
        session.injectedData = "testData".data(using: .utf8)

        var isSuccessfullSpy = false
        var dataSpy: MockDataBuildable?
        _ = sut.load(request) { (result: Result<MockDataBuildable, ApiError>) in
            isSuccessfullSpy = result.isSuccess
            dataSpy = result.result
        }
        XCTAssertTrue(isSuccessfullSpy)
        XCTAssertEqual(dataSpy?.test, "testData")
    }

    func test_load_shouldCallCompletion_withFailure_whenSuccessfullCall() {
        session.injectedData = "testData".data(using: .utf8)
        session.injectedResponse = HTTPURLResponse(url: URL(string: "http://apple.com")!,
                                                   statusCode: 300,
                                                   httpVersion: nil,
                                                   headerFields: nil)
        var isSuccessfullSpy = false
        _ = sut.load(request) { (result: Result<MockDataBuildable, ApiError>) in
            isSuccessfullSpy = result.isSuccess
            XCTAssertEqual(result.error?.code, 300)
            XCTAssertEqual(result.error?.message, "Error 300 MockDataBuildable(test: \"testData\")")
        }
        XCTAssertFalse(isSuccessfullSpy)
    }

    func test_load_shouldCallCompletion_withFailure_whenThereIsAnError () {
        session.injectedError = NSError(domain: "", code: 100, userInfo: nil)
        session.injectedData = "testData".data(using: .utf8)

        var isSuccessfullSpy = true
        var dataSpy: MockDataBuildable?
        _ = sut.load(request) { (result: Result<MockDataBuildable, ApiError>) in
            isSuccessfullSpy = result.isSuccess
            dataSpy = result.result
        }
        XCTAssertFalse(isSuccessfullSpy)
        XCTAssertNil(dataSpy)
    }

    func test_load_shouldCallCompletion_withFailure_whenThereIsNoData () {
        var isSuccessfullSpy = true
        var dataSpy: MockDataBuildable?
        _ = sut.load(request) { (result: Result<MockDataBuildable, ApiError>) in
            isSuccessfullSpy = result.isSuccess
            dataSpy = result.result
        }
        XCTAssertFalse(isSuccessfullSpy)
        XCTAssertNil(dataSpy)
    }

    func test_loadImage_shouldCallCompletion_withSussess_whenSuccessfullCall_successfullImage () {
        session.injectedData = makeImage().pngData()
        let image = UIImage(data: session.injectedData!)
        let comparisonData = image!.pngData()
        var isSuccessfullSpy = false
        var imageSpy: UIImage?
        _ = sut.load(URLRequest(url: imageUrl)) { (result: Result<UIImage, ApiError>) in
            isSuccessfullSpy = result.isSuccess
            imageSpy = result.result
        }
        guard let receivedImage = imageSpy else {
            return XCTFail("image need to exist to proceed with the test")
        }
        XCTAssertTrue(isSuccessfullSpy)
        XCTAssertEqual(comparisonData, receivedImage.pngData())
    }

    func test_loadImage_shouldCallCompletion_withFailure_whenThereIsAnError () {
        session.injectedError = NSError(domain: "", code: 100, userInfo: nil)
        session.injectedData = "testData".data(using: .utf8)

        var isSuccessfullSpy = true
        var dataSpy: UIImage?
        _ = sut.load(URLRequest(url: imageUrl)) { (result: Result<UIImage, ApiError>) in
            isSuccessfullSpy = result.isSuccess
            dataSpy = result.result
        }
        XCTAssertFalse(isSuccessfullSpy)
        XCTAssertNil(dataSpy)
    }

    func test_loadImage_shouldCallCompletion_withFailure_whenThereIsNoValitImageData () {
        session.injectedData = "testData".data(using: .utf8)
        var isSuccessfullSpy = true
        var dataSpy: UIImage?
        var error: ApiError?
        _ = sut.load(URLRequest(url: imageUrl)) { (result: Result<UIImage, ApiError>) in
            isSuccessfullSpy = result.isSuccess
            dataSpy = result.result
            error = result.error
        }
        XCTAssertFalse(isSuccessfullSpy)
        XCTAssertEqual(dataSpy, nil)
        XCTAssertEqual(error?.code, 3000)
    }

    func test_loadData_shouldCallCompletion_withSussess_whenSuccessfullCall() {
        session.injectedData = "testData".data(using: .utf8)

        var isSuccessfullSpy = false
        var dataSpy: Data?
        _ = sut.load(request) { (result: Result<Data, ApiError>) in
            isSuccessfullSpy = result.isSuccess
            dataSpy = result.result
        }
        XCTAssertTrue(isSuccessfullSpy)
        XCTAssertEqual(session.injectedData, dataSpy)
    }

    func test_loadData_shouldCallCompletion_withFailure_whenThereIsAnError () {
        session.injectedError = NSError(domain: "", code: 100, userInfo: nil)
        session.injectedData = "testData".data(using: .utf8)

        var isSuccessfullSpy = true
        var dataSpy: Data?
        _ = sut.load(request) { (result: Result<Data, ApiError>) in
            isSuccessfullSpy = result.isSuccess
            dataSpy = result.result
        }
        XCTAssertFalse(isSuccessfullSpy)
        XCTAssertNil(dataSpy)
    }

    func test_loadData_shouldCallCompletion_withFailure_whenThereIsNoData () {
        var isSuccessfullSpy = true
        var dataSpy: Data?
        _ = sut.load(request) { (result: Result<Data, ApiError>) in
            isSuccessfullSpy = result.isSuccess
            dataSpy = result.result
        }
        XCTAssertFalse(isSuccessfullSpy)
        XCTAssertEqual(dataSpy, nil)
    }

    func test_loadData_shouldGetCacheWhenAvailable() {
        guard let data = "testData".data(using: .utf8) else {
            return XCTFail("Data should exist for make this test valid")
        }
        session.injectedData = data
        cache.injectedCachedURLResponse = CachedURLResponse(response: URLResponse(), data: data)
        _ = sut.load(request, cache: cache) { _ in }
        XCTAssertEqual(cache.cachedResponseCounter, 1)
        XCTAssertEqual(cache.requestSpy, request)
    }

    func test_loadData_shouldStoreCache() {
        session.injectedData = "testData".data(using: .utf8)
        session.injectedResponse = HTTPURLResponse()

        _ = sut.load(request, cache: cache) { (_ : Result<Data, ApiError>) in }
        XCTAssertEqual(cache.storeCachedResponseCounter, 1)
    }

    func test_load_shouldGetCacheWhenAvailable() {
        guard let data = "testData".data(using: .utf8) else {
            return XCTFail("this test need data to run")
        }
       session.injectedData = data

        cache.injectedCachedURLResponse = CachedURLResponse(response: URLResponse(), data: data)
        _ = sut.load(request, cache: cache) { (_: Result<MockDataBuildable, ApiError>) in }
        XCTAssertEqual(cache.cachedResponseCounter, 1)
        XCTAssertEqual(cache.requestSpy, request)
    }

    func test_load_shouldStoreCache() {
        session.injectedData = "testData".data(using: .utf8)
        session.injectedResponse = HTTPURLResponse()

        _ = sut.load(request, cache: cache) { (_: Result<MockDataBuildable, ApiError>) in }
        XCTAssertEqual(cache.storeCachedResponseCounter, 1)
    }

    func test_cacheCache_removeCahce() {
        sut.cleanCache(cache)
        XCTAssertEqual(cache.removeCounter, 1)
    }

}
