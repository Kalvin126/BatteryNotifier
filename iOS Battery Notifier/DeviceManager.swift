//
//  DeviceManager.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/17/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Foundation
import SDMMobileDevice


class DeviceManager : NSObject {

    // Can listen for notification kSDMMD_USBMuxListenerDeviceAttachedNotificationFinished as well

    static func refreshDevices() -> [Device] {
        var devices = [Device]();

        let deviceList = SDMMD_AMDCreateDeviceList().takeUnretainedValue()
        print("Fetched \((deviceList as NSArray).count) devices")

        for iosDev in deviceList as NSArray {
            let rawDevice = unsafeBitCast(iosDev, SDMMD_AMDeviceRef.self)
            let newDevice = Device(withDevice: rawDevice)

            devices.append(newDevice)
        }

        devices.forEach {
            if $0.batteryCapacity < 40 {
                let userNotif = NSUserNotification()
                userNotif.title = "Low Battery: \($0.name)"
                userNotif.subtitle = "40% of battery remaining"

                userNotif.soundName = NSUserNotificationDefaultSoundName

                NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(userNotif)
            }
        }

        return devices
    }
}

struct Device {
    let name: String // kDeviceName
    let UUID: String // kUniqueDeviceID
    let serialNumber: String // kSerialNumber

    let batteryCharging: Bool // kBatteryIsCharging
    let fullyCharged: Bool // kFullyCharged
    let batteryCapacity: Int // kBatteryCurrentCapacity

    init(withDevice device:SDMMD_AMDeviceRef) {
        var kr: sdmmd_return_t

        kr = SDMMD_AMDeviceConnect(device)
        if kr != Int32(kAMDSuccess.rawValue) {
            print(kr)
        }
        kr = SDMMD_AMDeviceStartSession(device)
        if kr != Int32(kAMDSuccess.rawValue) {
            print(kr)
        }
        print("Connected")

        let getValue = { (domain: UnsafePointer<Int8>, key: UnsafePointer<Int8>) -> AnyObject in
            let cfDomain: CFStringRef = CFStringCreateWithCString(kCFAllocatorDefault, domain, 0)
            let cfKey: CFStringRef = CFStringCreateWithCString(kCFAllocatorDefault, key, 0)
            let retVal = SDMMD_AMDeviceCopyValue(device, cfDomain, cfKey)

            if retVal != nil {
                return retVal.takeUnretainedValue()
            } else {
                return "0"
            }
        }

        name         = String(getValue("NULL", kDeviceName    ) as! CFString)
        serialNumber = String(getValue("NULL", kSerialNumber  ) as! CFString)
        UUID         = String(getValue("NULL", kUniqueDeviceID) as! CFString)

        batteryCharging = Bool(getValue(kBatteryDomain, kBatteryIsCharging     ) as! CFBoolean)
        fullyCharged    = Bool(getValue(kBatteryDomain, kFullyCharged          ) as! CFBoolean)
        batteryCapacity =  Int(getValue(kBatteryDomain, kBatteryCurrentCapacity) as! CFNumber )

        kr = SDMMD_AMDeviceStopSession(device)
        if kr != Int32(kAMDSuccess.rawValue) {
            print(kr)
        }
        kr = SDMMD_AMDeviceDisconnect(device)
        if kr != Int32(kAMDSuccess.rawValue) {
            print(kr)
        }
        print("Disconnected from \(name)")
    }

    /*
    //kAMDSuccess
    //kAMDInvalidResponseError
    //kAMDDeviceDisconnectedError
    //kAMDSessionInactiveError
    */
}