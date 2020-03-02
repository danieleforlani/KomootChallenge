//
//  ApiError.swift
//  AppFoundation
//
//  Created by Daniele Forlani on 25/07/2019.
//  Copyright © 2019 Attio. All rights reserved.
//

import Foundation

public struct ApiError: Codable {
    public let code: Int
    public let message: String

    public init(code: Int, message: String) {
        self.code = code
        self.message = message
    }

    enum CodingKeys: String, CodingKey {
        case code = "statusCode"
        case message = "errorMessage"
    }
}

extension ApiError {
    static func build(with error: Error) -> ApiError {
        let nsError = error as NSError
        let code = nsError.code
        let message = nsError.domain + ": " + (nsError.userInfo[errorMessageKey] as? String ?? unknowError.message)
        return ApiError(code: code, message: message)
    }

    public static func build(from data: Data) -> ApiError? {
        return JSONDecoder.decode(ApiError.self, from: data)
    }
}
extension ApiError: Equatable { }
