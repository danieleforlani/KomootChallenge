//
//  Mocks.swift
//  MarksAndSpencerTests
//
//  Created by Daniele Forlani on 13/10/2018.
//  Copyright © 2018 Scheggia. All rights reserved.
//

import Foundation
import LocalAuthentication
import UIKit
@testable import AppFoundation
import XCTest

class MockNetworking: NetworkingType {

    var cleanCacheCounter = 0
    func cleanCache(_ cache: CacheType) {
        cleanCacheCounter += 1
    }

    var cleanCookiesCounter = 0
    func cleanCookies(_ storage: HTTPCookieStorage) {
        cleanCookiesCounter += 1
    }

    func loadEnriched<T>(_ request: URLRequest,
                         completion: @escaping (Result<T, ApiError>) -> Void) -> URLSessionDataTask?
        where T: DataBuildable {
            loadCounter += 1
            requestSpy = request
            if injectedSuccess,
                let image = injectedImage as? T {
                completion(.success(image))
                return dataTask
            }

            if injectedSuccess,
                let data = injectedData,
                let buildable = T.build(from: data) as? T {
                completion(.success(buildable))
                return dataTask
            }
            completion(.failure(injectedError))
            return dataTask
    }

    var token: String = "Bearer null"
    var urlSessionSpy: URLSession
    var dataTask = URLSession.shared.dataTask(with: URL(string: "http://www.apple.com")!)

    required init(_ session: URLSession, dispatchable: DispatchableType = MockDispatchable()) {
        self.urlSessionSpy = session
    }

    var loadCounter = 0
    var requestSpy: URLRequest?
    var injectedData: Data?
    var injectedImage: UIImage?
    var injectedSuccess: Bool = true
    var injectedError = unknowError

    func load<T>(_ request: URLRequest,
                 completion: @escaping (Result<T, ApiError>) -> Void) -> URLSessionDataTask? where T: DataBuildable {
        loadCounter += 1
        requestSpy = request
        if injectedSuccess,
            let image = injectedImage as? T {
            completion(.success(image))
            return dataTask
        }

        if injectedSuccess,
            let data = injectedData,
            let buildable = T.build(from: data) as? T {
            completion(.success(buildable))
            return dataTask
        }
        completion(.failure(injectedError))
        return dataTask
    }

    func load<T>(_ request: URLRequest,
                 cache: CacheType,
                 completion: @escaping (Result<T, ApiError>) -> Void) -> URLSessionDataTask? where T: DataBuildable {
        loadCounter += 1
        requestSpy = request
        if injectedSuccess,
            let image = injectedImage as? T {
            completion(.success(image))
            return dataTask
        }

        if injectedSuccess,
            let data = injectedData,
            let buildable = T.build(from: data) as? T {
            completion(.success(buildable))
            return dataTask
        }
        completion(.failure(injectedError))
        return dataTask
    }
}

class MockUrlSession: URLSession {

    var injectedError: Error?
    var injectedData: Data?
    var injectedResponse: HTTPURLResponse?
    var dataTask: MockDataTask?
    var requestSpy: URLRequest?

    override func dataTask(with request: URLRequest,
                           completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTask = MockDataTask()
        requestSpy = request
        completionHandler(injectedData, injectedResponse, injectedError)
        guard let dataTask = dataTask else {
            XCTFail("data task need to exist for the test to run")
            return URLSession.shared.dataTask(with: URL(string: "http://www.apple.com")!)
        }
        return dataTask
    }

    override init() {
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

class MockDispatchable: DispatchableType {

    func mainAsync(after delay: Int, _ block: @escaping () -> Void) {
        mainCounter += 1
        block()
    }

    var mainCounter = 0
    func mainAsync(_ block: @escaping () -> Void) {
        mainCounter += 1
        block()
    }
}

class MockNavigationController: UINavigationController {
    var pushViewControllerCounter = 0
    var viewControllerSpy: UIViewController?
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushViewControllerCounter += 1
        viewControllerSpy = viewController
    }
}

class MockViewController: UIViewController {

    var presentCounter = 0
    var viewControllerToPresentSpy: UIViewController?
    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool,
                          completion: (() -> Void)? = nil) {
        presentCounter += 1
        viewControllerToPresentSpy = viewControllerToPresent
    }
}

class MockCollectionView: UICollectionView {
    var reloadDataCounter = 0
    override func reloadData() {
        reloadDataCounter += 1
    }
}

func makeImage() -> UIImage {
    let size = CGSize(width: 100, height: 100)
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    UIColor.red.setFill()
    UIRectFill(rect)
    guard let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
        return UIImage()
    }
    UIGraphicsEndImageContext()
    return image
}

extension NSCoder {
    static func empty() -> NSCoder {
        let data = Data()

        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        archiver.encode(data, forKey: "Attio")
        archiver.finishEncoding()
        guard let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data) else {
            fatalError()
        }
        return unarchiver
    }
}

struct MockDataBuildable: Codable, DataBuildable {
    var test: String

    static func build(from data: Data) -> MockDataBuildable? {
        guard let string = String(data: data, encoding: .utf8) else { return nil }
        return MockDataBuildable(test: string)
    }
}

class MockTimer: NSObject, TimerType {

    static func scheduledTimer(timeInterval: TimeInterval,
                               target aTarget: Any,
                               selector aSelector: Selector) -> TimerType {
        let timer = MockTimer()
        timer.localFireDate = Date().addingTimeInterval(timeInterval)
        let target = aTarget as? NSObject
        target?.perform(aSelector)
        return timer
    }

    var isValid: Bool {
        return localIsValid
    }

    var localFireDate: Date = Date()
    var localIsValid: Bool = true
    var invalidateCounter = 0
    var block: (() -> Void)?
    private var timer = Timer(timeInterval: 1000, repeats: false) { _ in }

    var fireDate: Date {
        return localFireDate
    }

    func invalidate() {
        localIsValid = false
        invalidateCounter += 1
    }
}

class MockHTTPCookieStorage: HTTPCookieStorage {
    var removeCounter = 0
    override func deleteCookie(_ cookie: HTTPCookie) {
        removeCounter += 1
    }
}

class MockCache: CacheType {
    var removeCounter = 0
    func removeAllCachedResponses() {
        removeCounter += 1
    }

    var cachedResponseCounter = 0
    var requestSpy: URLRequest?
    var injectedCachedURLResponse: CachedURLResponse?
    func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        cachedResponseCounter += 1
        requestSpy = request
        return injectedCachedURLResponse
    }

    var cachedResponseSpy: CachedURLResponse?
    var storeCachedResponseCounter = 0
    func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest) {
        storeCachedResponseCounter += 1
        cachedResponseSpy = cachedResponse
    }
}
