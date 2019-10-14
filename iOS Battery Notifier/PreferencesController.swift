//
//  PreferencesController.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/22/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

final class PreferencesController: NSViewController {

    private var userDefaults: UserDefaults { .standard }
    private var bundle: Bundle { .main }

    // MARK: Subviews

    @IBOutlet weak var versionField: NSTextField!

    @IBOutlet weak var lowBatteryNotificationsCheckBox: NSButton!
    @IBOutlet weak var showPercentageCheckBox: NSButton!

    @IBOutlet weak var notificationIntervalField: NSTextField!
    @IBOutlet weak var notificationIntervalStepper: NSStepper!

    @IBOutlet weak var lowBatteryThresholdField: NSTextField!
    @IBOutlet weak var lowBatteryThresholdStepper: NSStepper!

    @IBOutlet weak var snoozeIntervalField: NSTextField!
    @IBOutlet weak var snoozeIntervalStepper: NSStepper!

    // MARK: NSViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        let version = bundle.infoDictionary!["CFBundleShortVersionString"]!
        versionField.cell?.title = "v\(version)"

        let userDefaults = UserDefaults.standard

        showPercentageCheckBox.state = (userDefaults.bool(forKey: "ShowMenuPercentage") ? .on : .off)
        lowBatteryNotificationsCheckBox.state = (userDefaults.bool(forKey: "LowBatteryNotificationsOn") ? .on : .off)

        lowBatteryThresholdField.cell?.title = "\(userDefaults.integer(forKey: "BatteryThreshold"))%"
        lowBatteryThresholdStepper.integerValue = userDefaults.integer(forKey: "BatteryThreshold")

        notificationIntervalField.cell?.title = String(format: "%.2f", userDefaults.double(forKey: "NotificationInterval"))
        notificationIntervalStepper.doubleValue = userDefaults.double(forKey: "NotificationInterval")

        snoozeIntervalField.cell?.title = "\(userDefaults.integer(forKey: "SnoozeInterval"))"
        snoozeIntervalStepper.integerValue = userDefaults.integer(forKey: "SnoozeInterval")
    }

}

// MARK: - Events
extension PreferencesController {

    @IBAction func toggledMenuPercentage(sender: NSButton) {
        let userDefaults = UserDefaults.standard
        let on = (sender.state == .on ? true : false)

        userDefaults.set(on, forKey: "ShowMenuPercentage")
    }

    @IBAction func toggledLowBatteryNotifications(sender: NSButton) {
        let isOn = sender.state == .on

        userDefaults.set(isOn, forKey: "LowBatteryNotificationsOn")
    }

    @IBAction func clickedLowBatteryThreshholdStepper(sender: NSStepper) {
        let newThreshold = sender.integerValue

        lowBatteryThresholdField.cell?.title = "\(newThreshold)%"

        userDefaults.set(newThreshold, forKey: "BatteryThreshold")
    }

    @IBAction func clickedNotificationIntervalStepper(sender: NSStepper) {
        let newInterval = sender.doubleValue

        notificationIntervalField.cell?.title = String(format: "%.2f", newInterval)

        userDefaults.set(newInterval, forKey: "NotificationInterval")
    }

    @IBAction func clickedSnoozeIntervalIntervalStepper(sender: NSStepper) {
        let newInterval = sender.integerValue

        snoozeIntervalField.cell?.title = "\(newInterval)"

        userDefaults.set(newInterval, forKey: "SnoozeInterval")
    }

    @IBAction func clickedGitHub(sender: NSButton) {
        guard let url = URL(string: "https://GitHub.com/Kalvin126/BatteryNotifier") else { return }

        NSWorkspace.shared.open(url)
    }

    @IBAction func clickedLinkedIn(sender: NSButton) {
        guard let url = URL(string: "https://LinkedIn.com/in/KalvinLoc") else { return }

        NSWorkspace.shared.open(url)
    }

}
