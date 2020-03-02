//
//  JsonEncoderHelper.swift
//  AppFoundation
//
//  Created by Daniele Forlani on 16/07/2019.
//  Copyright © 2019 Attio. All rights reserved.
//

import Foundation

public extension JSONDecoder {
    static func decode<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(type, from: data)
    }
}

public extension JSONEncoder {
    static func encode<T: Encodable>(_ value: T) -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(value)
    }
}
