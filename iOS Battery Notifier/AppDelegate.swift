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
final class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItemController = StatusItemController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSUserNotificationCenter.default.delegate = self

        let userDefaults = UserDefaults.standard

        if !(userDefaults.dictionaryRepresentation().keys.contains("NotificationInterval")) {
            // Default values
            userDefaults.set(true, forKey: "LowBatteryNotificationsOn")
            userDefaults.set(false, forKey: "ShowMenuPercentage")
            userDefaults.set(2.0, forKey: "NotificationInterval")
            userDefaults.set(30, forKey: "BatteryThreshold")
            userDefaults.set(10, forKey: "SnoozeInterval")
        }

        // Reset device history
        let sharedDefaults = UserDefaults(suiteName: "group.redpanda.BatteryNotifier")!
        sharedDefaults.removeObject(forKey: "Devices")
        sharedDefaults.synchronize()

        InitializeSDMMobileDevice()
        statusItemController.startMonitoring()

        DeviceManager.shared.delegate = statusItemController
    }

}

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
