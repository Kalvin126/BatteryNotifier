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

    let name: String // kDeviceName
    let serialNumber: String // kSerialNumber

    let deviceClass : String // kDeviceClass

    let isBatteryCharging: Bool // kBatteryIsCharging
    let batteryCapacity: Int // kBatteryCurrentCapacity

    var isSnoozed = false

    // MARK: Init

    init(device: SDMMD_AMDeviceRef) {
        SDMMD_AMDeviceConnect(device)
        SDMMD_AMDeviceStartSession(device)

        let getValue = { (domain: UnsafePointer<Int8>, key: UnsafePointer<Int8>) -> AnyObject in
            let cfDomain: CFString = CFStringCreateWithCString(kCFAllocatorDefault, domain, 0)
            let cfKey: CFString = CFStringCreateWithCString(kCFAllocatorDefault, key, 0)
            guard let device = SDMMD_AMDeviceCopyValue(device, cfDomain, cfKey) else {
                return "0" as CFString
            }

            return device.takeUnretainedValue()
        }

        name         = String(getValue("NULL", kDeviceName    ) as! CFString)
        deviceClass  = String(getValue("NULL", kDeviceClass   ) as! CFString)
        serialNumber = String(getValue("NULL", kSerialNumber  ) as! CFString)

        isBatteryCharging = CFBooleanGetValue((getValue(kBatteryDomain, kBatteryIsCharging) as! CFBoolean))
        batteryCapacity = ((getValue(kBatteryDomain, kBatteryCurrentCapacity) as! CFNumber) as NSNumber).intValue

        SDMMD_AMDeviceStopSession(device)
        SDMMD_AMDeviceDisconnect(device)
    }

    init?(dictionary: [String: AnyObject]) {
        guard let name = dictionary["Name"] as? String,
            let deviceClass = dictionary["Class"] as? String,
            let serialNumber = dictionary["Serial"] as? String,
            let batteryCharging = dictionary["BatteryCharging"] as? Bool,
            let batteryCapacity = dictionary["LastKnownBatteryLevel"] as? Int else {
                return nil
        }

        self.name = name
        self.deviceClass = deviceClass
        self.serialNumber = serialNumber
        self.isBatteryCharging = batteryCharging
        self.batteryCapacity = batteryCapacity
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
