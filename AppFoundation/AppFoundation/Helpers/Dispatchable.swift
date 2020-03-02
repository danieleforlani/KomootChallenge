//
//  Dispatchable.swift
//  MarksAndSpencer
//
//  Created by Daniele Forlani on 13/10/2018.
//  Copyright © 2018 Scheggia. All rights reserved.
//

import Foundation
import UIKit

public protocol DispatchableType {
    func mainAsync(_ block: @escaping () -> Void)
    func mainAsync(after delay: Int, _ block: @escaping () -> Void)
}

public class Dispatchable: DispatchableType {

    public init() {}

    public func mainAsync(_ block: @escaping () -> Void) {
        guard !Thread.current.isMainThread else {
            return block()
        }
        DispatchQueue.main.async {
            block()
        }
    }

    public func mainAsync(after delay: Int, _ block: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(delay)) {
            block()
        }
    }
}
