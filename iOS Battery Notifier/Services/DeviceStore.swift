//
//  DeviceStore.swift
//  BatteryNotifier
//
//  Created by Kalvin Loc on 10/16/19.
//  Copyright © 2019 Red Panda. All rights reserved.
//

import Foundation

// TODO: Debut Output

struct DeviceStore {

    private static var sharedStore: UserDefaults? { UserDefaults.sharedSuite }

    private static var encoder: PropertyListEncoder {
        let encoder = PropertyListEncoder()

        encoder.outputFormat = .binary

        return encoder
    }
    private static var decoder: PropertyListDecoder { .init() }

}

// MARK: - Storing Devices
extension DeviceStore {

    static func storeDevices(_ devices: [Device]) {
        guard let data = try? encoder.encode(devices) else { return }

        sharedStore?.set(data, forKey: .devices)
    }

}

// MARK: - Getting Devices
extension DeviceStore {

    static func getDevices() -> [Device]? {
        guard let deviceData = sharedStore?.data(forKey: .devices) else { return nil }
        var format: PropertyListSerialization.PropertyListFormat = .binary

        return try? decoder.decode([Device].self,
                                   from: deviceData,
                                   format: &format)
    }

}
