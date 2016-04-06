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

        let userDefaults = NSUserDefaults.standardUserDefaults()

        if !(userDefaults.dictionaryRepresentation().keys.contains("NotificationInterval")) {
            // Default values
            userDefaults.setBool(true, forKey: "LowBatteryNotificationsOn")
            userDefaults.setBool(false, forKey: "ShowMenuPercentage")
            userDefaults.setDouble(2.0, forKey: "NotificationInterval")
            userDefaults.setInteger(40, forKey: "BatteryThreshold")
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
