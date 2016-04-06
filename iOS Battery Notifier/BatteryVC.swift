//
//  BatteryVC.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/18/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

class BatteryVC: NSViewController {

    @IBOutlet private var batteryView: BatteryView!

    var enabled = false {
        didSet {
            if enabled {
                setTheme(nil)
            } else {
                batteryView.defaultColor = NSColor.darkGrayColor().CGColor
            }
        }
    }

    var displayedDevice: Device? {
        didSet {
            enabled = (displayedDevice != nil)

            batteryView.charging = displayedDevice?.batteryCharging ?? false
            batteryView.fillLevelByPercent(displayedDevice?.batteryCapacity ?? 0)
        }
    }

    var whiteThemeOnly = false {
        didSet {
            batteryView.defaultColor = NSColor.whiteColor().CGColor
        }
    }

    deinit {
        let center = NSDistributedNotificationCenter.defaultCenter()
        center.removeObserver(self, name: "AppleInterfaceThemeChangedNotification", object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        batteryView.setup()

        // Status bar theme change
        let center = NSDistributedNotificationCenter.defaultCenter()
        let notif = "AppleInterfaceThemeChangedNotification"
        center.addObserver(self, selector: #selector(setTheme(_:)), name: notif, object: nil)
    }

    func setTheme(notification: NSNotification?) {
        guard !whiteThemeOnly else { return }

        let darkMode = NSUserDefaults.standardUserDefaults().stringForKey("AppleInterfaceStyle") == "Dark"
        batteryView.defaultColor = (darkMode ? NSColor.whiteColor() : NSColor.blackColor()).CGColor
    }
    
}
