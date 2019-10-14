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
    private var deviceTimers = [String : Timer]()
    private var deviceNotificationTimers = [String : Timer]()

    // MARK: Static funcs
    
    static func refreshDevices() -> [Device] {
        var devices = [Device]();

        let deviceList = SDMMD_AMDCreateDeviceList().takeRetainedValue()

        for iosDev in deviceList as NSArray {
            let rawDevice = unsafeBitCast(iosDev, to: SDMMD_AMDeviceRef.self)
            guard SDMMD_AMDeviceIsAttached(rawDevice) else { continue }

            let newDevice = Device(withDevice: rawDevice)
            guard newDevice.name != "0" && newDevice.serialNumber != "0" else { continue }

            NSLog("DeviceManager: Fetched \(newDevice.name) at \(newDevice.batteryCapacity)")

            devices.append(newDevice)

            DispatchQueue.main.async {
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

    static private func recordDevice(_ device: Device) {
        let deviceSnoozed = shared.devices[device.serialNumber]?.snoozed ?? false
        shared.devices[device.serialNumber] = device
        shared.devices[device.serialNumber]?.snoozed = deviceSnoozed

        let sharedDefaults = UserDefaults(suiteName: "group.redpanda.BatteryNotifier")!
        var devicesDict = sharedDefaults.dictionary(forKey: "Devices") ?? [String : AnyObject]()
        var deviceDict = [String : AnyObject]()

        deviceDict["Name"] = device.name as AnyObject
        deviceDict["Class"] = device.deviceClass as AnyObject
        deviceDict["Serial"] = device.serialNumber as AnyObject

        deviceDict["BatteryCharging"] = device.batteryCharging as AnyObject
        deviceDict["LastKnownBatteryLevel"] = NSNumber(value: device.batteryCapacity)

        devicesDict[device.serialNumber] = deviceDict
        sharedDefaults.set(devicesDict, forKey: "Devices")
        sharedDefaults.synchronize()
    }

    // MARK: Instance funcs

    override init() {
        super.init()

        // Observe LowBatteryNotificationsOn changes
        UserDefaults.standard.addObserver(self, forKeyPath: "LowBatteryNotificationsOn", options: .new, context: nil)
    }

    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: "LowBatteryNotificationsOn")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "LowBatteryNotificationsOn" {
            // Remove all pending notifications if turned off, notifications re enabled upon device re-connection
            if let newChange = change?[.newKey] as? Int,
                newChange == 0 {
                removeAllNotificationTimers()
            }
        }
    }

    private func handleLowBatteryNotification(forDevice device: Device) {
        let userDefaults = UserDefaults.standard

        // Do not need to send notification if below threshold, is charging or notifications not on
        guard !(device.batteryCharging) ||
            device.batteryCapacity <= userDefaults.integer(forKey: "BatteryThreshold") else {
            removeLowBatteryNotification(forSerial: device.serialNumber)
            return
        }

        if  deviceNotificationTimers[device.serialNumber] == nil &&
            device.batteryCapacity <= userDefaults.integer(forKey: "BatteryThreshold") &&
            devices[device.serialNumber]!.snoozed == false &&
            userDefaults.bool(forKey: "LowBatteryNotificationsOn") {

            updateLowBatteryNotificationTimer(forSerial: device.serialNumber)
        }

    }

    private func updateLowBatteryNotificationTimer(forSerial serial: String) {
        let userDefaults = UserDefaults.standard

        guard !(devices[serial]!.batteryCharging) else { return }

        if deviceNotificationTimers[serial] == nil {
            let interval = userDefaults.double(forKey: "NotificationInterval")*60.0
            let timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(sendLowBatteryNotification(timer:)), userInfo: serial, repeats: true)
            
            timer.fire()
            deviceNotificationTimers[serial] = timer
        }
    }

    @objc func sendLowBatteryNotification(timer: Timer) {
        let sharedDefaults = UserDefaults(suiteName: "group.redpanda.BatteryNotifier")!
        let devicesDict = sharedDefaults.dictionary(forKey: "Devices")!
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

        NSUserNotificationCenter.default.deliver(userNotif)
    }

    func snoozeDevice(deviceInfo: [String : AnyObject]) {
        devices[deviceInfo["Serial"] as! String]?.snoozed = true
        removeLowBatteryNotification(forSerial: deviceInfo["Serial"] as! String)

        let userDefaults = UserDefaults.standard
        let deadline = DispatchTime.now() + .seconds(userDefaults.integer(forKey: "SnoozeInterval")*60)

        // dispatch re-enabling of notification timer after snooze interval
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.devices[deviceInfo["Serial"] as! String]?.snoozed = false
            self.updateLowBatteryNotificationTimer(forSerial: deviceInfo["Serial"] as! String)
        }
    }

    private func removeLowBatteryNotification(forSerial serial: String) {
        deviceNotificationTimers[serial]?.invalidate()
        deviceNotificationTimers.removeValue(forKey: serial)
    }

    private func removeAllNotificationTimers() {
        Array(deviceNotificationTimers.keys).forEach { removeLowBatteryNotification(forSerial: $0) }
    }

    // removes device records if device has not been synced for 30 minutes
    func updateDeviceTimer(forDevice device: Device) {
        let timer = Timer.scheduledTimer(timeInterval: 30*60,
                                         target: self,
                                         selector: #selector(invalidateDevice(timer:)),
                                         userInfo: device.serialNumber,
                                         repeats: false)

        deviceTimers[device.serialNumber]?.invalidate()
        deviceTimers[device.serialNumber] = timer
    }

    @objc func invalidateDevice(timer: Timer) {
        let deviceSerial = timer.userInfo as! String
        devices.removeValue(forKey: deviceSerial)
        deviceTimers.removeValue(forKey: deviceSerial)
        removeLowBatteryNotification(forSerial: deviceSerial)

        // remove from sharedDefaults
        let sharedDefaults = UserDefaults(suiteName: "group.redpanda.BatteryNotifier")!
        var devicesDict = sharedDefaults.dictionary(forKey: "Devices")! // Device has been recorded before so deviceDict must exist

        devicesDict.removeValue(forKey: deviceSerial)
        
        sharedDefaults.set(devicesDict, forKey: "Devices")
        sharedDefaults.synchronize()

        delegate?.expirationMetForDevice(serial: deviceSerial)
    }

}
