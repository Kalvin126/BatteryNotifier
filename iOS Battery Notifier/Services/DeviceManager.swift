//
//  DeviceManager.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/17/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa
import SDMMobileDevice

protocol DeviceObserver: class {

    func deviceManager(_ manager: DeviceManager, didFetch devices: [Device])

    func deviceManager(_ manager: DeviceManager, expirationMetFor device: Device)

}

final class DeviceManager {

    private var weakObservers: [Weak<AnyObject>] = [] {
        didSet {
            weakObservers.reap()
        }
    }
    private var observers: [DeviceObserver] {
        return (weakObservers.compactMapStrong as? [DeviceObserver]) ?? []
    }

    private(set) var devices: [Device.SerialNumber: Device] = [:]

    private var deviceTimers = [Device.SerialNumber: Timer]()

    // MARK: Init

    init() {
        observeDeviceAttached()
    }

}

// MARK: - Observing Devices
extension DeviceManager {

    private func observeDeviceAttached() {
        NSLog("DeviceManager: Listening for iOS devices...")

        DarwinNotificationsManager.default
            .observeNotification(forName: "SDMMD_USBMuxListenerDeviceAttachedNotification") { [weak self] in
                #if DEBUG
                print("Recieved SDMMD_USBMuxListenerDeviceAttachedNotification")
                #endif

                guard let self = self else { return }

                self.refresh()
        }
    }

}

// MARK: - Fetching Devices
extension DeviceManager {
    
    func refresh() {
        DispatchQueue.global(qos: .default).async {
            self.refreshDevices()
        }
    }

    private func refreshDevices() {
        guard let deviceInfo = DeviceProxy.getDeviceInformation() else { return }

        deviceInfo.forEach {
            guard let device = Device(dictionary: $0) else { return }

            NSLog("DeviceManager: Fetched \(device.name) at \(device.batteryCapacity)")

            recordDevice(device)
//            handleLowBatteryNotification(forDevice: device)
            updateDeviceTimer(forDevice: device)

            self.devices[device.serialNumber] = device
        }

        DispatchQueue.main.async {
            self.observers.forEach {
                $0.deviceManager(self, didFetch: Array(self.devices.values))
            }
        }
    }

    private func recordDevice(_ device: Device) {
//        let deviceSnoozed = shared.devices[device.serialNumber]?.isSnoozed ?? false
//        shared.devices[device.serialNumber] = device
//        shared.devices[device.serialNumber]?.isSnoozed = deviceSnoozed
//
//        let sharedDefaults = UserDefaults.sharedSuite!
//        var devicesDict = sharedDefaults.dictionary(forKey: "Devices") ?? [String : AnyObject]()
//        var deviceDict = [String : AnyObject]()
//
//        deviceDict["Name"] = device.name as AnyObject
//        deviceDict["Class"] = device.deviceClass as AnyObject
//        deviceDict["Serial"] = device.serialNumber as AnyObject
//
//        deviceDict["BatteryCharging"] = device.isBatteryCharging as AnyObject
//        deviceDict["LastKnownBatteryLevel"] = NSNumber(value: device.batteryCapacity)
//
//        devicesDict[device.serialNumber] = deviceDict
//        sharedDefaults.set(devicesDict, forKey: "Devices")
//        sharedDefaults.synchronize()
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
//        removeLowBatteryNotification(forSerial: deviceSerial)

        // remove from sharedDefaults
        let sharedDefaults = UserDefaults.sharedSuite!
        var devicesDict = sharedDefaults.dictionary(forKey: .devices)! // Device has been recorded before so deviceDict must exist

        devicesDict.removeValue(forKey: deviceSerial)
        
        sharedDefaults.set(devicesDict, forKey: .devices)
        sharedDefaults.synchronize()


//        DispatchQueue.main.async {
//            weakObservers.compactMapStrong.forEach {
//                $0.deviceManager(self, expirationMetFor: device)
//            }
//        }
    }

}

// MARK: - Observing Devices
extension DeviceManager {

    func addObserver(_ observer: DeviceObserver) {
        weakObservers.append(Weak(observer))
    }

    func removeObserver(_ observer: DeviceObserver) {
        guard let index = weakObservers.firstIndex(where: { $0 === observer }) else { return }

        weakObservers.remove(at: index)
    }

}

// MARK: - Events
private extension DeviceManager {

    func didFetchDevices(_ devices: [Device]) {

    }

}
