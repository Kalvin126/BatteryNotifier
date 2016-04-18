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
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItemController = StatusItemController()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self

        let userDefaults = NSUserDefaults.standardUserDefaults()

        if !(userDefaults.dictionaryRepresentation().keys.contains("NotificationInterval")) {
            // Default values
            userDefaults.setBool(true, forKey: "LowBatteryNotificationsOn")
            userDefaults.setBool(false, forKey: "ShowMenuPercentage")
            userDefaults.setDouble(2.0, forKey: "NotificationInterval")
            userDefaults.setInteger(30, forKey: "BatteryThreshold")
            userDefaults.setInteger(10, forKey: "SnoozeInterval")
        }

        // Reset device history
        let sharedDefaults = NSUserDefaults(suiteName: "group.redpanda.BatteryNotifier")!
        sharedDefaults.removeObjectForKey("Devices")
        sharedDefaults.synchronize()

        InitializeSDMMobileDevice()
        statusItemController.startMonitoring()

        DeviceManager.shared.delegate = statusItemController
    }

}

extension AppDelegate: NSUserNotificationCenterDelegate {

    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }

    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {

        switch notification.activationType {

        case .ActionButtonClicked:
            DeviceManager.shared.snoozeDevice(notification.userInfo!)

        default:
            break
        }

    }

}
