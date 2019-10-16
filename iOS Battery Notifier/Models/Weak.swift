//
//  Weak.swift
//  BatteryNotifier
//
//  Created by Kalvin Loc on 10/14/19.
//  Copyright © 2019 Red Panda. All rights reserved.
//

import Foundation

final class Weak<T: AnyObject> {

    weak var value: T?

    // MARK: Init

    init(_ value: T) {
        self.value = value
    }

}

extension Array where Element: Weak<AnyObject> {

    mutating func reap() {
        self = filter { $0.value != nil }
    }

    var compactMapStrong: [AnyObject] { compactMap { $0.value } }

}
