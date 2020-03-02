//
//  NotificationCenterHelper.swift
//  AppFoundationTests
//
//  Created by Daniele Forlani on 17/10/2019.
//  Copyright © 2019 Attio. All rights reserved.
//

import Foundation

public protocol NotificationCenterType {
    func addObserver(_ observer: Any,
                     selector aSelector: Selector,
                     name aName: NSNotification.Name?,
                     object anObject: Any?)
}
extension NotificationCenter: NotificationCenterType { }
