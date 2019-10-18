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

        showPercentageCheckBox.state = (userDefaults.bool(forKey: .showMenuPercentage) ? .on : .off)
        lowBatteryNotificationsCheckBox.state = (userDefaults.bool(forKey: .lowBatteryNotificationsOn) ? .on : .off)

        let batteryThreshold = userDefaults.integer(forKey: .batteryThreshold)
        lowBatteryThresholdField.cell?.title = "\(batteryThreshold)%"
        lowBatteryThresholdStepper.integerValue = batteryThreshold

        notificationIntervalField.cell?.title = String(format: "%.2f", userDefaults.double(forKey: .notificationInterval))
        notificationIntervalStepper.doubleValue = userDefaults.double(forKey: .notificationInterval)

        snoozeIntervalField.cell?.title = "\(userDefaults.integer(forKey: .snoozeInterval))"
        snoozeIntervalStepper.integerValue = userDefaults.integer(forKey: .snoozeInterval)
    }

}

// MARK: - Events
extension PreferencesController {

    @IBAction func toggledMenuPercentage(sender: NSButton) {
        let userDefaults = UserDefaults.standard
        let on = (sender.state == .on ? true : false)

        userDefaults.set(on, forKey: .showMenuPercentage)
    }

    @IBAction func toggledLowBatteryNotifications(sender: NSButton) {
        let isOn = sender.state == .on

        userDefaults.set(isOn, forKey: .lowBatteryNotificationsOn)
    }

    @IBAction func clickedLowBatteryThreshholdStepper(sender: NSStepper) {
        let newThreshold = sender.integerValue

        lowBatteryThresholdField.cell?.title = "\(newThreshold)%"

        userDefaults.set(newThreshold, forKey: .batteryThreshold)
    }

    @IBAction func clickedNotificationIntervalStepper(sender: NSStepper) {
        let newInterval = sender.doubleValue

        notificationIntervalField.cell?.title = String(format: "%.2f", newInterval)

        userDefaults.set(newInterval, forKey: .notificationInterval)
    }

    @IBAction func clickedSnoozeIntervalIntervalStepper(sender: NSStepper) {
        let newInterval = sender.integerValue

        snoozeIntervalField.cell?.title = "\(newInterval)"

        userDefaults.set(newInterval, forKey: .snoozeInterval)
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
