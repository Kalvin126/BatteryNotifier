//
//  PreferencesController.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/22/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

class PreferencesController: NSViewController {

    @IBOutlet weak var lowBatteryNotificaitonsCheckBox: NSButton!
    @IBOutlet weak var notificationIntervalField: NSTextField!
    @IBOutlet weak var notificationIntervalStepper: NSStepper!

    @IBOutlet weak var lowBatteryThresholdField: NSTextField!
    @IBOutlet weak var lowBatteryThresholdStepper: NSStepper!

    override func viewDidLoad() {
        super.viewDidLoad()

        let userDefaults = NSUserDefaults.standardUserDefaults()

        lowBatteryNotificaitonsCheckBox.state = (userDefaults.boolForKey("LowBatteryNotificationsOn") ? NSOnState : NSOffState)

        notificationIntervalField.cell?.title = String(format: "%.2f", userDefaults.doubleForKey("NotificationInterval"))
        notificationIntervalStepper.doubleValue = userDefaults.doubleForKey("NotificationInterval")

        lowBatteryThresholdField.cell?.title = "\(userDefaults.integerForKey("BatteryThreshold"))%"
        lowBatteryThresholdStepper.integerValue = userDefaults.integerForKey("BatteryThreshold")
    }

    // MARK: IBActions

    @IBAction func toggledLowBatteryNotifications(sender: NSButton) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let on = (sender.state == NSOnState ? true : false)

        userDefaults.setBool(on, forKey: "LowBatteryNotificationsOn")
    }

    @IBAction func clickedNotificationIntervalStepper(sender: NSStepper) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let newInterval = sender.doubleValue

        notificationIntervalField.cell?.title = String(format: "%.2f", newInterval)

        userDefaults.setDouble(newInterval, forKey: "NotificationInterval")
    }

    @IBAction func clickedLowBatteryThreshholdStepper(sender: NSStepper) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let newThreshold = sender.integerValue

        lowBatteryThresholdField.cell?.title = "\(newThreshold)%"

        userDefaults.setInteger(newThreshold, forKey: "BatteryThreshold")
    }

    @IBAction func clickedGitHub(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://GitHub.com/Kalvin126/BatteryNotifier")!)
    }

    @IBAction func clickedLinkedIn(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://LinkedIn.com/in/KalvinLoc")!)
    }
}
