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
                setTheme(notification: nil)
            } else {
                batteryView.defaultColor = NSColor.darkGray.cgColor
            }
        }
    }

    var displayedDevice: Device? {
        didSet {
            enabled = (displayedDevice != nil)

            batteryView.charging = displayedDevice?.batteryCharging ?? false
            batteryView.fillLevel(by: displayedDevice?.batteryCapacity ?? 0)
        }
    }

    var whiteThemeOnly = false {
        didSet {
            batteryView.defaultColor = NSColor.white.cgColor
        }
    }

    deinit {
        let center = DistributedNotificationCenter.default
        center.removeObserver(self, name: .appleInterfaceThemeChangedNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        batteryView.setup()

        // Status bar theme change
        let center = DistributedNotificationCenter.default
        center.addObserver(self,
                           selector: #selector(setTheme(notification:)),
                           name: .appleInterfaceThemeChangedNotification,
                           object: nil)
    }

    @objc func setTheme(notification: NSNotification?) {
        guard !whiteThemeOnly else { return }

        let darkMode = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
        batteryView.defaultColor = (darkMode ? NSColor.white : NSColor.black).cgColor
    }
    
}
