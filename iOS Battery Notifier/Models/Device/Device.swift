//
//  Device.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/25/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Foundation
import SDMMobileDevice

struct Device {

    typealias SerialNumber = String

    let name: String // kDeviceName
    let serialNumber: SerialNumber // kSerialNumber

    let deviceClass : String // kDeviceClass

    let isBatteryCharging: Bool // kBatteryIsCharging
    let currentBatteryCapacity: Int // kBatteryCurrentCapacity

    // MARK: Init

    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String,
            name != "0",
            let deviceClass = dictionary["deviceClass"] as? String,
            let serialNumber = dictionary["serialNumber"] as? String,
            serialNumber != "0",
            let batteryCharging = dictionary["isBatteryCharging"] as? Bool,
            let batteryCapacity = dictionary["batteryCapacity"] as? Int else {
                return nil
        }

        self.name = name
        self.deviceClass = deviceClass
        self.serialNumber = serialNumber
        self.isBatteryCharging = batteryCharging
        self.currentBatteryCapacity = batteryCapacity
    }

    /* TODO: response handling?
     //kAMDSuccess
     //kAMDInvalidResponseError
     //kAMDDeviceDisconnectedError
     //kAMDSessionInactiveError
     */
}

// MARK: - Equatable
extension Device: Equatable {

    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.serialNumber == rhs.serialNumber
    }

}

// MARK: - Hashable
extension Device: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(serialNumber)
    }

}

// MARK: - Identifiable
extension Device: Identifiable {

    var id: String { serialNumber }

}

// MARK: - Codable
extension Device: Codable { }
