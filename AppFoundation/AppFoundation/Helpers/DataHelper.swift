//
//  DataHelper.swift
//  AppFoundation
//
//  Created by Daniele Forlani on 06/08/2019.
//  Copyright © 2019 Attio. All rights reserved.
//

import Foundation

extension Data {
    public var escaped: Data? {
        let unescapedData = String(data: self, encoding: .utf8)
        return unescapedData?.replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\\\"", with: "\\\\\"").data(using: .utf8)
    }
}
