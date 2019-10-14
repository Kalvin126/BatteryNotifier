//
//  Device.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/25/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Foundation
import SDMMobileDevice

struct Device : Equatable {
    let name: String // kDeviceName
    let deviceClass : String // kDeviceClass
    let serialNumber: String // kSerialNumber

    let batteryCharging: Bool // kBatteryIsCharging
    let batteryCapacity: Int // kBatteryCurrentCapacity

    var snoozed = false

    init(withDevice device:SDMMD_AMDeviceRef) {
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

        batteryCharging = CFBooleanGetValue((getValue(kBatteryDomain, kBatteryIsCharging) as! CFBoolean))
        batteryCapacity = ((getValue(kBatteryDomain, kBatteryCurrentCapacity) as! CFNumber) as NSNumber).intValue

        SDMMD_AMDeviceStopSession(device)
        SDMMD_AMDeviceDisconnect(device)
    }

    init(withDictionary dict: [String : AnyObject]) {
        name         = dict["Name"] as! String
        deviceClass  = dict["Class"] as! String
        serialNumber = dict["Serial"] as! String

        batteryCharging = dict["BatteryCharging"] as! Bool
        batteryCapacity = dict["LastKnownBatteryLevel"] as! Int
    }

    /* TODO: response handling?
     //kAMDSuccess
     //kAMDInvalidResponseError
     //kAMDDeviceDisconnectedError
     //kAMDSessionInactiveError
     */
}

func ==(lhs: Device, rhs: Device) -> Bool {
    return lhs.serialNumber == rhs.serialNumber
}
