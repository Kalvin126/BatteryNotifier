//
//  NotificationsHandler.swift
//  BatteryNotifier
//
//  Created by Kalvin Loc on 10/14/19.
//  Copyright © 2019 Red Panda. All rights reserved.
//

import Cocoa

final class NotificationsHandler: NSObject {

    private var deviceNotificationTimers: [Device.SerialNumber: Timer] = [:]
    private var devices: [Device] = []

    private let userDefaults = UserDefaults.standard

    // MARK: Notification Thresholds

    private var batteryThreshold: Int { userDefaults.integer(forKey: .batteryThreshold) }
    private var snoozeInterval: Int { userDefaults.integer(forKey: "SnoozeInterval") }

    // MARK: Init

    override init() {
        super.init()

        UserDefaults.standard.addObserver(self,
                                          forKeyPath: ConfigKey.lowBatteryNotificationsOn.id,
                                          options: .new,
                                          context: nil)
    }

    deinit {
        UserDefaults.standard.removeObserver(self,
                                             forKeyPath: ConfigKey.lowBatteryNotificationsOn.id)
    }

    // MARK: NSKeyValueObserving

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == ConfigKey.lowBatteryNotificationsOn.id {
            // Remove all pending notifications if turned off, notifications re-enabled upon device re-connection
            if let newChange = change?[.newKey] as? Int,
                newChange == 0 {
                removeAllNotificationTimers()
            }
        }
    }

}

// MARK: - Actions
extension NotificationsHandler {

    private func removeLowBatteryNotification(for serial: Device.SerialNumber) {
        deviceNotificationTimers[serial]?.invalidate()
        deviceNotificationTimers.removeValue(forKey: serial)
    }

    private func removeAllNotificationTimers() {
        deviceNotificationTimers.keys.forEach {
            removeLowBatteryNotification(for: $0)
        }
    }

    private func snoozeDevice(_ device: Device) {
        guard deviceNotificationTimers.keys.contains(device.serialNumber) else { return }

        removeLowBatteryNotification(for: device.serialNumber)

        let deadline = DispatchTime.now() + .seconds(snoozeInterval*60)

        // dispatch re-enabling of notification timer after snooze interval
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.updateLowBatteryNotificationTimer(for: device)
        }
    }

    private func updateLowBatteryNotification(for device: Device) {
        guard !device.isBatteryCharging ||
            device.batteryCapacity <= batteryThreshold else {
                removeLowBatteryNotification(for: device.serialNumber)
                return
        }

        guard deviceNotificationTimers[device.serialNumber] == nil,
            device.batteryCapacity <= userDefaults.integer(forKey: .batteryThreshold),
            userDefaults.bool(forKey: .lowBatteryNotificationsOn) else { return }

        updateLowBatteryNotificationTimer(for: device)
    }

    private func updateLowBatteryNotificationTimer(for device: Device) {
        guard !device.isBatteryCharging else { return }

        guard deviceNotificationTimers[device.serialNumber] == nil else { return }

        let interval = userDefaults.double(forKey: .notificationInterval)*60.0
        let timer = Timer.scheduledTimer(timeInterval: interval,
                                         target: self,
                                         selector: #selector(sendLowBatteryNotification(timer:)),
                                         userInfo: device.serialNumber,
                                         repeats: true)

        timer.fire()
        deviceNotificationTimers[device.serialNumber] = timer

    }

    @objc func sendLowBatteryNotification(timer: Timer) {
        guard let deviceSerialNumber = timer.userInfo as? String,
            let device = devices.first(where: { $0.serialNumber == deviceSerialNumber }) else { return }
        let userInfo = ["deviceSerialNumber": deviceSerialNumber]

        let notification = NSUserNotification()
        notification.title = "Low Battery: \(device.name)"
        notification.subtitle = "\(device.batteryCapacity)% of battery remaining"
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.userInfo = userInfo

        // Private
        notification.actionButtonTitle = "Snooze"
        notification.setValue(true, forKey: "_showsButtons")
        notification.setValue(NSImage(named: "lowBattery"), forKey: "_identityImage")
        notification.setValue(false, forKey: "_identityImageHasBorder")

        NSUserNotificationCenter.default.deliver(notification)
    }

}

// MARK: - Events
extension NotificationsHandler { }

// MARK: - DeviceObserver
extension NotificationsHandler: DeviceObserver {

    func deviceManager(_ manager: DeviceManager, didFetch devices: [Device]) {
        self.devices = devices
        // TODO: remove notifications for old devices
    }

    func deviceManager(_ manager: DeviceManager, expirationMetFor device: Device) { }

}

// MARK: - NSUserNotificationCenterDelegate
extension NotificationsHandler: NSUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        switch notification.activationType {
        case .actionButtonClicked:
            guard let deviceSerialNumber = notification.userInfo?["deviceSerialNumber"] as? String,
                let device = devices.first(where: { $0.serialNumber == deviceSerialNumber }) else { return }

            snoozeDevice(device)

        default:
            break
        }
    }

}
