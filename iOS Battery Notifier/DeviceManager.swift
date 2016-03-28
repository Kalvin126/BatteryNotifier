//
//  DeviceManager.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/17/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa
import SDMMobileDevice

class DeviceManager : NSObject {
    

    static func refreshDevices() -> [Device] {
        var devices = [Device]();

        let deviceList = SDMMD_AMDCreateDeviceList().takeRetainedValue()

        for iosDev in deviceList as NSArray {
            let rawDevice = unsafeBitCast(iosDev, SDMMD_AMDeviceRef.self)
            guard SDMMD_AMDeviceIsAttached(rawDevice) else { continue }

            let newDevice = Device(withDevice: rawDevice)
            guard newDevice.name != "0" else { continue }

            NSLog("DeviceManager: Fetched \(newDevice.name) at \(newDevice.batteryCapacity)")

            devices.append(newDevice)

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                // Low Battery Notifications
                DeviceManager.recordDevice(newDevice)
                DeviceManager.sendLowBatteryNotification(forDevice: newDevice)
            }
        }

        return devices
    }

    static private func recordDevice(device: Device) {
        let sharedDefaults = NSUserDefaults(suiteName: "group.redpanda.BatteryNotifier")!
        var devicesDict = sharedDefaults.dictionaryForKey("Devices") ?? [String : AnyObject]()  // Nil Coalescing!
        var deviceDict = [String : AnyObject]()

        deviceDict["Name"] = device.name
        deviceDict["Class"] = device.deviceClass
        deviceDict["Serial"] = device.serialNumber

        deviceDict["BatteryCharging"] = device.batteryCharging
        deviceDict["LastKnownBatteryLevel"] = NSNumber(integer: device.batteryCapacity)

        devicesDict[device.serialNumber] = deviceDict
        sharedDefaults.setObject(devicesDict, forKey: "Devices")
        sharedDefaults.synchronize()
    }

    static private func sendLowBatteryNotification(forDevice device: Device) {
        let userDefaults = NSUserDefaults.standardUserDefaults()

        // Do not need to send notification if below threshold, is charging or notifications not on
        guard device.batteryCapacity <= userDefaults.integerForKey("BatteryThreshold") &&
              !(device.batteryCharging)  &&
              userDefaults.boolForKey("LowBatteryNotificationsOn") else { return }

        let sharedDefaults = NSUserDefaults(suiteName: "group.redpanda.BatteryNotifier")!
        var devicesDict = sharedDefaults.dictionaryForKey("Devices")!
        var deviceDict = devicesDict[device.serialNumber] as! [String : AnyObject]
        var sendNotification = false

        // device has had a notification sent before
        if let timeSinceLastNotif = deviceDict["TimeSinceLastNotification"] as? NSDate {
            if timeSinceLastNotif.timeIntervalSinceNow > (userDefaults.doubleForKey("NotificationInterval"))/60.0 {
                NSLog("DeviceManager: Battery notification sent for \(device.name)")
                sendNotification = true
            }
        } else {
            sendNotification = true
        }

        if sendNotification {
            let userNotif = NSUserNotification()
            userNotif.title = "Low Battery: \(device.name)"
            userNotif.subtitle = "\(device.batteryCapacity)% of battery remaining"
            userNotif.soundName = NSUserNotificationDefaultSoundName
            userNotif.setValue(NSImage(named: "lowBattery"), forKey: "_identityImage")
            userNotif.setValue(false, forKey: "_identityImageHasBorder")

            deviceDict["TimeSinceLastNotification"] = NSDate()

            devicesDict[device.serialNumber] = deviceDict
            sharedDefaults.setObject(devicesDict, forKey: "Devices")

            NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(userNotif)
            sharedDefaults.synchronize()
        }
    }

}
