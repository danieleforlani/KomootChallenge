//
//  Result.swift
//  MarksAndSpencer
//
//  Created by Daniele Forlani on 13/10/2018.
//  Copyright © 2018 Scheggia. All rights reserved.
//

import Foundation

public enum Result<ResultType, ErrorType> {
    case success(ResultType)
    case failure(ErrorType)
}

extension Result {

    public var result: ResultType? {
        guard case .success(let result) = self else {
            return nil
        }
        return result
    }

    public var error: ErrorType? {
        guard case .failure(let error) = self else {
            return nil
        }
        return error
    }

    public var isSuccess: Bool {
        guard case .success = self else {
            return false
        }

        return true
    }
}
