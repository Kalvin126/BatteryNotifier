//
//  UserDefaults.swift
//  BatteryNotifier
//
//  Created by Kalvin Loc on 10/13/19.
//  Copyright © 2019 Red Panda. All rights reserved.
//

import Foundation

// MARK: - Accessing UserDefault Suites
extension UserDefaults {

    static var sharedSuite: UserDefaults? {
        UserDefaults(suiteName: "group.redpanda.BatteryNotifier")
    }

}

// MARK: - Getting Default Values with ConfigKey
extension UserDefaults {

    func object(forKey key: ConfigKey) -> Any? {
        object(forKey: key.id)
    }

    func url(forKey key: ConfigKey) -> URL? {
        url(forKey: key.id)
    }

    func array(forKey key: ConfigKey) -> [Any]? {
        array(forKey: key.id)
    }

    func dictionary(forKey key: ConfigKey) -> [String: Any]? {
        dictionary(forKey: key.id)
    }

    func string(forKey key: ConfigKey) -> String? {
        string(forKey: key.id)
    }

    func stringArray(forKey key: ConfigKey) -> [String]? {
        stringArray(forKey: key.id)
    }

    func data(forKey key: ConfigKey) -> Data? {
        data(forKey: key.id)
    }

    func bool(forKey key: ConfigKey) -> Bool {
        bool(forKey: key.id)
    }

    func integer(forKey key: ConfigKey) -> Int {
        integer(forKey: key.id)
    }

    func float(forKey key: ConfigKey) -> Float {
        float(forKey: key.id)
    }

    func double(forKey key: ConfigKey) -> Double {
        double(forKey: key.id)
    }

}

// MARK: - Setting Default Values with ConfigKey
extension UserDefaults {

    func set(_ value: Any?, forKey key: ConfigKey) {
        set(value, forKey: key.id)
    }

    func set(_ value: Float, forKey key: ConfigKey) {
        set(value, forKey: key.id)
    }

    func set(_ value: Double, forKey key: ConfigKey) {
        set(value, forKey: key.id)
    }

    func set(_ value: Int, forKey key: ConfigKey) {
        set(value, forKey: key.id)
    }

    func set(_ value: Bool, forKey key: ConfigKey) {
        set(value, forKey: key.id)
    }

    func set(_ value: URL?, forKey key: ConfigKey) {
        set(value, forKey: key.id)
    }

}

// MARK: - Removing Defaults
extension UserDefaults {

    func removeObject(forKey key: ConfigKey) {
        removeObject(forKey: key.id)
    }

}
