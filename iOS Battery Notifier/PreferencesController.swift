//
//  PreferencesController.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/22/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

class PreferencesController: NSViewController {

    @IBOutlet weak var versionField: NSTextField!

    @IBOutlet weak var lowBatteryNotificationsCheckBox: NSButton!
    @IBOutlet weak var showPercentageCheckBox: NSButton!

    @IBOutlet weak var notificationIntervalField: NSTextField!
    @IBOutlet weak var notificationIntervalStepper: NSStepper!

    @IBOutlet weak var lowBatteryThresholdField: NSTextField!
    @IBOutlet weak var lowBatteryThresholdStepper: NSStepper!

    @IBOutlet weak var snoozeIntervalField: NSTextField!
    @IBOutlet weak var snoozeIntervalStepper: NSStepper!

    override func viewDidLoad() {
        super.viewDidLoad()

        let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]!
        versionField.cell?.title = "v\(version)"

        let userDefaults = NSUserDefaults.standardUserDefaults()

        showPercentageCheckBox.state = (userDefaults.boolForKey("ShowMenuPercentage") ? NSOnState : NSOffState)
        lowBatteryNotificationsCheckBox.state = (userDefaults.boolForKey("LowBatteryNotificationsOn") ? NSOnState : NSOffState)

        lowBatteryThresholdField.cell?.title = "\(userDefaults.integerForKey("BatteryThreshold"))%"
        lowBatteryThresholdStepper.integerValue = userDefaults.integerForKey("BatteryThreshold")

        notificationIntervalField.cell?.title = String(format: "%.2f", userDefaults.doubleForKey("NotificationInterval"))
        notificationIntervalStepper.doubleValue = userDefaults.doubleForKey("NotificationInterval")

        snoozeIntervalField.cell?.title = "\(userDefaults.integerForKey("SnoozeInterval"))"
        snoozeIntervalStepper.integerValue = userDefaults.integerForKey("SnoozeInterval")
    }

    // MARK: IBActions

    @IBAction func toggledMenuPercentage(sender: NSButton) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let on = (sender.state == NSOnState ? true : false)

        userDefaults.setBool(on, forKey: "ShowMenuPercentage")
    }

    @IBAction func toggledLowBatteryNotifications(sender: NSButton) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let on = (sender.state == NSOnState ? true : false)

        userDefaults.setBool(on, forKey: "LowBatteryNotificationsOn")
    }

    @IBAction func clickedLowBatteryThreshholdStepper(sender: NSStepper) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let newThreshold = sender.integerValue

        lowBatteryThresholdField.cell?.title = "\(newThreshold)%"

        userDefaults.setInteger(newThreshold, forKey: "BatteryThreshold")
    }

    @IBAction func clickedNotificationIntervalStepper(sender: NSStepper) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let newInterval = sender.doubleValue

        notificationIntervalField.cell?.title = String(format: "%.2f", newInterval)

        userDefaults.setDouble(newInterval, forKey: "NotificationInterval")
    }

    @IBAction func clickedSnoozeIntervalIntervalStepper(sender: NSStepper) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let newInterval = sender.integerValue

        snoozeIntervalField.cell?.title = "\(newInterval)"

        userDefaults.setInteger(newInterval, forKey: "SnoozeInterval")
    }

    @IBAction func clickedGitHub(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://GitHub.com/Kalvin126/BatteryNotifier")!)
    }

    @IBAction func clickedLinkedIn(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://LinkedIn.com/in/KalvinLoc")!)
    }
}
