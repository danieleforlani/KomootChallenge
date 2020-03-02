//
//  Constants.swift
//  
//
//  Created by Daniele Forlani on 14/03/2019.
//  Copyright © 2019 Attio. All rights reserved.
//

import Foundation

let contenTypeKey = "Content-Type"
let contenType = "application/json"
let acceptHeaderKey = "Accept"
let acceptHeader = "application/json, text/plain, */*"

let dateFormatter = ISO8601DateFormatter()
let sentTimeFormatter = DateFormatter()
let sentDateFormatter = DateFormatter()
let sentDateYearFormatter = DateFormatter()

let errorMessageKey = "message"

let activeWorkspace = "activeWorkspace"

public let unknowError = ApiError(code: 3000, message: "Something went wrong, please retry later.")
public let networkError = ApiError(code: 3001, message: "It seems we are having a network issue, retry later.")
public let initialisingError = ApiError(code: 3002, message: "Something went wrong, please retry later.")
public let urlComposerError = ApiError(code: 3004, message: "Something went wrong, please retry later.")
