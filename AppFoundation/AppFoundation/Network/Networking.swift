//
//  Networking.swift
//  MarksAndSpencer
//
//  Created by Daniele Forlani on 13/10/2018.
//  Copyright © 2018 Scheggia. All rights reserved.
//

import UIKit

public protocol NetworkingType {
    init(_ session: URLSession, dispatchable: DispatchableType)
    func load<T: DataBuildable>(_ request: URLRequest,
                                completion: @escaping (Result<T, ApiError>) -> Void) -> URLSessionDataTask?
    func load(_ request: URLRequest,
              completion: @escaping (Result<Data, ApiError>) -> Void) -> URLSessionDataTask?
    func cleanCache(_ cache: CacheType)
}

public protocol DataBuildable {
    associatedtype ResultType
    static func build(from data: Data) -> ResultType?
}

extension UIImage: DataBuildable {
    public static func build(from data: Data) -> UIImage? {
        return UIImage(data: data)
    }
}

extension Data {
    func parseJson<T: Decodable>() -> T? {
        guard let model = try? JSONDecoder().decode(T.self, from: self) else {
            return nil
        }
       return model
    }
}

public protocol CacheType {
    func cachedResponse(for request: URLRequest) -> CachedURLResponse?
    func storeCachedResponse(_ cachedResponse: CachedURLResponse, for request: URLRequest)
    func removeAllCachedResponses()
}
extension URLCache: CacheType {}

public class Networking: NetworkingType {
    private var session: URLSession
    private var dispatchable: DispatchableType

    required public init(_ session: URLSession = URLSession.shared, dispatchable: DispatchableType = Dispatchable()) {
        self.session = session
        self.dispatchable = dispatchable
    }

    public func load<T: DataBuildable>
        (_ request: URLRequest,
         completion: @escaping (Result<T, ApiError>) -> Void) -> URLSessionDataTask? {

        load(request, cache: URLCache.shared, completion: completion)
    }

    public func load<T: DataBuildable>
        (_ request: URLRequest,
         cache: CacheType?,
         completion: @escaping (Result<T, ApiError>) -> Void) -> URLSessionDataTask? {

        if request.httpMethod == HTTPMethod.GET.rawValue,
            let cache = cache,
            let data = cache.cachedResponse(for: request)?.data,
            let result: T = T.build(from: data) as? T {
            completion(.success(result))
        }

        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                completion(.failure(ApiError.build(with: error)))
                return
            }
            guard let data = data else {
                completion(.failure(networkError))
                return
            }
            if let apiError = ApiError.build(from: data) {
                completion(.failure(apiError))
                return
            }

            guard let result: T = T.build(from: data) as? T else {
                var appError = unknowError
                if let error = String(data: data, encoding: .utf8),
                    let httpResponse = response as? HTTPURLResponse {
                    appError = ApiError(code: httpResponse.statusCode, message: error)
                }
                completion(.failure(appError))
                return
            }

            if request.httpMethod == HTTPMethod.GET.rawValue,
                let response = response,
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode > 199,
                httpResponse.statusCode < 300,
                let cache = cache {
                cache.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
            }
            if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode > 299 {
                completion(.failure(ApiError(code: httpResponse.statusCode,
                                             message: "Error \(httpResponse.statusCode) \(result)")))
            } else {
                completion(.success(result))
            }
        })
        task.resume()
        return task
    }

    public func load(_ request: URLRequest,
                     completion: @escaping (Result<Data, ApiError>) -> Void) -> URLSessionDataTask? {
        load(request, cache: URLCache.shared, completion: completion)
    }

    public func load(_ request: URLRequest,
                     cache: CacheType,
                     completion: @escaping (Result<Data, ApiError>) -> Void) -> URLSessionDataTask? {

        if let data = cache.cachedResponse(for: request)?.data {
            self.dispatchable.mainAsync { completion(.success(data)) }
            return nil
        }
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                self.dispatchable.mainAsync { completion(.failure(ApiError.build(with: error))) }
                return
            }
            guard let data = data else {
                self.dispatchable.mainAsync { completion(.failure(networkError)) }
                return
            }
            if let apiError = ApiError.build(from: data) {
                return self.dispatchable.mainAsync { completion(.failure(apiError)) }
            }
            if let response = response {
                cache.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
            }
            self.dispatchable.mainAsync { completion(.success(data)) }
        })
        task.resume()
        return task
    }

    public func cleanCache(_ cache: CacheType = URLCache.shared) {
        cache.removeAllCachedResponses()
    }
}

public enum HTTPMethod: String {
    case DELETE
    case GET
    case POST
    case PUT
}
