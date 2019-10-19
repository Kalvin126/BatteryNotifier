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

    // MARK: Services

    private let deviceManager = DeviceManager()
    private let notificationsHandler = NotificationsHandler()

    // MARK: Views

    private let statusItemController = StatusItemController()

}

// MARK: - Actions
private extension AppDelegate {

    func setupServices() {
        InitializeSDMMobileDevice()

        deviceManager.addObserver(statusItemController)
        deviceManager.addObserver(notificationsHandler)
    }

    // MARK: User Preferences

    func resetDeviceHistory() {
        if let sharedDefaults = UserDefaults.sharedSuite {
            sharedDefaults.removeObject(forKey: .devices)
            sharedDefaults.synchronize()
        }
    }

    func setPreferencesDefaultsIfNeeded() {
        let userDefaults = UserDefaults.standard

        guard !userDefaults.dictionaryRepresentation().keys.contains(ConfigKey.notificationInterval.id) else { return }

        userDefaults.set(true, forKey: .lowBatteryNotificationsOn)
        userDefaults.set(false, forKey: .showMenuPercentage)
        userDefaults.set(2.0, forKey: .notificationInterval)
        userDefaults.set(30, forKey: .batteryThreshold)
        userDefaults.set(10, forKey: .snoozeInterval)
    }

}

// MARK: - NSApplicationDelegate
extension AppDelegate: NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSUserNotificationCenter.default.delegate = notificationsHandler

        setPreferencesDefaultsIfNeeded()
        resetDeviceHistory()

        setupServices()
    }

}
