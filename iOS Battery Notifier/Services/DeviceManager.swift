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

    func deviceManager(_ manager: DeviceManager, didFetch devices: Set<Device>)

    func deviceManager(_ manager: DeviceManager, didExpire device: Device)

}

final class DeviceManager {

    private(set) var devices: [Device.SerialNumber: Device] = [:]

    private var deviceTimers = [Device.SerialNumber: Timer]()

    private lazy var queue: DispatchQueue = DispatchQueue(label: "com.redpanda.DeviceManager",
                                                          qos: .default,
                                                          target: .global())

    // MARK: Constants

    private static var deviceExpirationInterval: TimeInterval = 30*60

    // MARK: Observers

    private var weakObservers: [Weak<AnyObject>] = [] {
        didSet {
            weakObservers.reap()
        }
    }
    private var observers: [DeviceObserver] {
        return (weakObservers.compactMapStrong as? [DeviceObserver]) ?? []
    }

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
        queue.async {
            self.refreshDevices()
        }
    }

    private func refreshDevices() {
        guard let deviceInfo = DeviceProxy.getDeviceInformation() else { return }

        deviceInfo.forEach {
            guard let device = Device(dictionary: $0) else { return }

            NSLog("DeviceManager: Fetched \(device.name) at \(device.currentBatteryCapacity)")

            updateTimer(for: device)

            self.devices[device.serialNumber] = device
        }

        DeviceStore.storeDevices(Array(self.devices.values))

        DispatchQueue.main.async {
            self.observers.forEach {
                $0.deviceManager(self, didFetch: Set(self.devices.values))
            }
        }
    }

}

// MARK: - Handling Device Lifetime
private extension DeviceManager {

    @objc func invalidateDevice(timer: Timer) {
        guard let deviceSerialNumber = timer.userInfo as? String else { return }

        queue.sync {
            self.deviceTimers.removeValue(forKey: deviceSerialNumber)

            if let device = self.devices[deviceSerialNumber] {
                self.devices.removeValue(forKey: deviceSerialNumber)

                DeviceStore.storeDevices(Array(self.devices.values))

                self.notifyDeviceExpiration(device: device)
            }
        }
    }

}

// MARK: - Handling Device Lifetime
private extension DeviceManager {

    /// Removes device records if device has not been synced for 30 minutes
    func updateTimer(for device: Device) {
        queue.sync {
            let timer = Timer.scheduledTimer(timeInterval: Self.deviceExpirationInterval,
                                             target: self,
                                             selector: #selector(invalidateDevice(timer:)),
                                             userInfo: device.serialNumber,
                                             repeats: false)

            deviceTimers[device.serialNumber]?.invalidate()
            deviceTimers[device.serialNumber] = timer
        }
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

// MARK: - Notifying Observers
private extension DeviceManager {

    func notifyDeviceExpiration(device: Device) {
        DispatchQueue.main.async {
            self.observers.forEach {
                $0.deviceManager(self, didExpire: device)
            }
        }
    }

}
