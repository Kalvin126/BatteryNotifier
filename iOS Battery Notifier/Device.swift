//
//  Device.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/25/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import SDMMobileDevice

struct Device : Equatable {
    let name: String // kDeviceName
    let deviceClass : String // kDeviceClass
    let serialNumber: String // kSerialNumber

    let batteryCharging: Bool // kBatteryIsCharging
    let batteryCapacity: Int // kBatteryCurrentCapacity

    init(withDevice device:SDMMD_AMDeviceRef) {
        SDMMD_AMDeviceConnect(device)
        SDMMD_AMDeviceStartSession(device)

        let getValue = { (domain: UnsafePointer<Int8>, key: UnsafePointer<Int8>) -> AnyObject in
            let cfDomain: CFStringRef = CFStringCreateWithCString(kCFAllocatorDefault, domain, 0)
            let cfKey: CFStringRef = CFStringCreateWithCString(kCFAllocatorDefault, key, 0)
            let retVal = SDMMD_AMDeviceCopyValue(device, cfDomain, cfKey)

            return (retVal != nil ? retVal.takeUnretainedValue() : "0")
        }

        name         = String(getValue("NULL", kDeviceName    ) as! CFString)
        deviceClass  = String(getValue("NULL", kDeviceClass   ) as! CFString)
        serialNumber = String(getValue("NULL", kSerialNumber  ) as! CFString)

        batteryCharging = Bool(getValue(kBatteryDomain, kBatteryIsCharging     ) as! CFBoolean)
        batteryCapacity =  Int(getValue(kBatteryDomain, kBatteryCurrentCapacity) as! CFNumber )

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
