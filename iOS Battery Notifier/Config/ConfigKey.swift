//
//  ConfigKey.swift
//  BatteryNotifier
//
//  Created by Kalvin Loc on 10/13/19.
//  Copyright © 2019 Red Panda. All rights reserved.
//

enum ConfigKey: String {

    case batteryThreshold
    case lowBatteryNotificationsOn
    case notificationInterval
    case showMenuPercentage
    case snoozeInterval

    // MARK: Shared

    case devices

    // MARK: System

    case appleInterfaceStyle = "AppleInterfaceStyle"

}

// MARK: - Identifiable
extension ConfigKey: Identifiable {

    var id: String { rawValue }

}
