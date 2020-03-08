//
//  InjectionContainer.swift
//  AppFoundation
//
//  Created by Scheggia on 02/03/2020.
//  Copyright © 2020 Attio. All rights reserved.
//

import Foundation

public protocol InjectionContainerType {
    func register<T>(_ protocolType: T.Type, buildBlock: @escaping () -> T?)
    func resolve<T>(_ protocolType: T.Type) -> T?
}

typealias InJectBlockType = () -> Any?

public class InjectionContainer: InjectionContainerType {

    var container: [String: InJectBlockType] = [:]

    public init() {}

    public func register<T>(_ protocolType: T.Type, buildBlock: @escaping () -> T?) {
        let convertedBuildBlock = buildBlock as InJectBlockType
        let key = "\(protocolType)"
        container[key] = convertedBuildBlock
    }

    public func resolve<T>(_ protocolType: T.Type) -> T? {
        container["\(protocolType)"]?() as? T
    }

}
