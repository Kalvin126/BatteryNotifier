//
//  DeviceManager.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/17/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa
import SDMMobileDevice

protocol DeviceManagerDelegate: class {
    func expirationMetForDevice(serial: String)
}

class DeviceManager : NSObject {

    static let shared = DeviceManager()
    weak var delegate: DeviceManagerDelegate?

    var devices = [String : Device]()
    private var deviceTimers = [String : NSTimer]()
    private var deviceNotificationTimers = [String : NSTimer]()

    // MARK: Static funcs
    
    static func refreshDevices() -> [Device] {
        var devices = [Device]();

        let deviceList = SDMMD_AMDCreateDeviceList().takeRetainedValue()

        for iosDev in deviceList as NSArray {
            let rawDevice = unsafeBitCast(iosDev, SDMMD_AMDeviceRef.self)
            guard SDMMD_AMDeviceIsAttached(rawDevice) else { continue }

            let newDevice = Device(withDevice: rawDevice)
            guard newDevice.name != "0" && newDevice.serialNumber != "0" else { continue }

            NSLog("DeviceManager: Fetched \(newDevice.name) at \(newDevice.batteryCapacity)")

            devices.append(newDevice)

            dispatch_async(dispatch_get_main_queue()) {
                // Low Battery Notifications
                recordDevice(newDevice)

                shared.handleLowBatteryNotification(forDevice: newDevice)
                shared.updateDeviceTimer(forDevice: newDevice)
            }
        }

        return devices
    }

    static func getAllDevices() -> [Device] {
        return Array(shared.devices.values)
    }

    static private func recordDevice(device: Device) {
        let deviceSnoozed = shared.devices[device.serialNumber]?.snoozed ?? false
        shared.devices[device.serialNumber] = device
        shared.devices[device.serialNumber]?.snoozed = deviceSnoozed

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

    // MARK: Instance funcs

    override init() {
        super.init()

        // Observe LowBatteryNotificationsOn changes
        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: "LowBatteryNotificationsOn", options: .New, context: nil)
    }

    deinit {
        NSUserDefaults.standardUserDefaults().removeObserver(self, forKeyPath: "LowBatteryNotificationsOn")
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "LowBatteryNotificationsOn" {
            // Remove all pending notifications if turned off, notifications re enabled upon device re-connection
            if change!["new"] as! Int == 0 {
                removeAllNotificationTimers()
            }
        }
    }

    private func handleLowBatteryNotification(forDevice device: Device) {
        let userDefaults = NSUserDefaults.standardUserDefaults()

        // Do not need to send notification if below threshold, is charging or notifications not on
        guard !(device.batteryCharging) ||
            device.batteryCapacity <= userDefaults.integerForKey("BatteryThreshold") else {
            removeLowBatteryNotification(forSerial: device.serialNumber)
            return
        }

        if  deviceNotificationTimers[device.serialNumber] == nil &&
            device.batteryCapacity <= userDefaults.integerForKey("BatteryThreshold") &&
            devices[device.serialNumber]!.snoozed == false &&
            userDefaults.boolForKey("LowBatteryNotificationsOn") {

            updateLowBatteryNotificationTimer(forSerial: device.serialNumber)
        }

    }

    private func updateLowBatteryNotificationTimer(forSerial serial: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()

        guard !(devices[serial]!.batteryCharging) else { return }

        if deviceNotificationTimers[serial] == nil {
            let interval = userDefaults.doubleForKey("NotificationInterval")*60.0
            let timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: #selector(sendLowBatteryNotification(_:)), userInfo: serial, repeats: true)
            
            timer.fire()
            deviceNotificationTimers[serial] = timer
        }
    }

    func sendLowBatteryNotification(timer: NSTimer) {
        let sharedDefaults = NSUserDefaults(suiteName: "group.redpanda.BatteryNotifier")!
        let devicesDict = sharedDefaults.dictionaryForKey("Devices")!
        let deviceDict = devicesDict[timer.userInfo as! String] as! [String : AnyObject]

        let userNotif = NSUserNotification()
        userNotif.title = "Low Battery: \(deviceDict["Name"]!)"
        userNotif.subtitle = "\(deviceDict["LastKnownBatteryLevel"]!)% of battery remaining"
        userNotif.soundName = NSUserNotificationDefaultSoundName
        userNotif.userInfo = deviceDict

        // Private
        userNotif.actionButtonTitle = "Snooze"
        userNotif.setValue(true, forKey: "_showsButtons")
        userNotif.setValue(NSImage(named: "lowBattery"), forKey: "_identityImage")
        userNotif.setValue(false, forKey: "_identityImageHasBorder")

        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(userNotif)
    }

    func snoozeDevice(deviceInfo: [String : AnyObject]) {
        devices[deviceInfo["Serial"] as! String]?.snoozed = true
        removeLowBatteryNotification(forSerial: deviceInfo["Serial"] as! String)

        let userDefaults = NSUserDefaults.standardUserDefaults()
        let interval = UInt64(userDefaults.integerForKey("SnoozeInterval"))*60

        // dispatch re-enabling of notification timer after snooze interval
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * NSEC_PER_SEC))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.devices[deviceInfo["Serial"] as! String]?.snoozed = false
            self.updateLowBatteryNotificationTimer(forSerial: deviceInfo["Serial"] as! String)
        }
    }

    private func removeLowBatteryNotification(forSerial serial: String) {
        deviceNotificationTimers[serial]?.invalidate()
        deviceNotificationTimers.removeValueForKey(serial)
    }

    private func removeAllNotificationTimers() {
        Array(deviceNotificationTimers.keys).forEach { removeLowBatteryNotification(forSerial: $0) }
    }

    // removes device records if device has not been synced for 30 minutes
    func updateDeviceTimer(forDevice device: Device) {
        let timer = NSTimer.scheduledTimerWithTimeInterval(30*60, target: self, selector: #selector(invalidateDevice(_:)), userInfo: device.serialNumber, repeats: false)

        deviceTimers[device.serialNumber]?.invalidate()
        deviceTimers[device.serialNumber] = timer
    }

    func invalidateDevice(timer: NSTimer) {
        let deviceSerial = timer.userInfo as! String
        devices.removeValueForKey(deviceSerial)
        deviceTimers.removeValueForKey(deviceSerial)
        removeLowBatteryNotification(forSerial: deviceSerial)

        // remove from sharedDefaults
        let sharedDefaults = NSUserDefaults(suiteName: "group.redpanda.BatteryNotifier")!
        var devicesDict = sharedDefaults.dictionaryForKey("Devices")! // Device has been recorded before so deviceDict must exist

        devicesDict.removeValueForKey(deviceSerial)
        
        sharedDefaults.setObject(devicesDict, forKey: "Devices")
        sharedDefaults.synchronize()

        delegate?.expirationMetForDevice(deviceSerial)
    }

}
