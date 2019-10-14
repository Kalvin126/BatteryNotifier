//
//  AppDelegate.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/15/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa
import SDMMobileDevice

@NSApplicationMain
final class AppDelegate: NSObject {

    let statusItemController = StatusItemController()

}

// MARK: - NSApplicationDelegate
extension AppDelegate: NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSUserNotificationCenter.default.delegate = self

        let userDefaults = UserDefaults.standard

        if !(userDefaults.dictionaryRepresentation().keys.contains(ConfigKey.notificationInterval.id)) {
            // Default values
            userDefaults.set(true, forKey: .lowBatteryNotificationsOn)
            userDefaults.set(false, forKey: .showMenuPercentage)
            userDefaults.set(2.0, forKey: .notificationInterval)
            userDefaults.set(30, forKey: .batteryThreshold)
            userDefaults.set(10, forKey: .snoozeInterval)
        }

        // Reset device history
        if let sharedDefaults = UserDefaults.sharedSuite {
            sharedDefaults.removeObject(forKey: .devices)
            sharedDefaults.synchronize()
        }

        InitializeSDMMobileDevice()
        statusItemController.startMonitoring()

        DeviceManager.shared.delegate = statusItemController
    }

}

// MARK: - NSUserNotificationCenterDelegate
extension AppDelegate: NSUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        switch notification.activationType {
        case .actionButtonClicked:
            DeviceManager.shared.snoozeDevice(deviceInfo: notification.userInfo! as [String : AnyObject])

        default:
            break
        }
    }

}
