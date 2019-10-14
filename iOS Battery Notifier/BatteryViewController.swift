//
//  BatteryViewController.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/18/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

final class BatteryViewController: NSViewController {

    var isEnabled = false {
        didSet {
            if isEnabled {
                setTheme(notification: nil)
            } else {
                batteryView.defaultColor = NSColor.darkGray.cgColor
            }
        }
    }

    var displayedDevice: Device? {
        didSet {
            isEnabled = (displayedDevice != nil)

            batteryView.charging = displayedDevice?.isBatteryCharging ?? false
            batteryView.fillLevel(by: displayedDevice?.batteryCapacity ?? 0)
        }
    }

    var whiteThemeOnly = false {
        didSet {
            batteryView.defaultColor = NSColor.white.cgColor
        }
    }

    // MARK: Subviews

    @IBOutlet private var batteryView: BatteryView!

    // MARK: Init

    deinit {
        let center = DistributedNotificationCenter.default
        center.removeObserver(self, name: .appleInterfaceThemeChangedNotification, object: nil)
    }

    // MARK: NSViewController

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


}

// MARK: - Actions
private extension BatteryViewController {

    @objc func setTheme(notification: NSNotification?) {
        guard !whiteThemeOnly else { return }

        let isDarkMode = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
        batteryView.defaultColor = (isDarkMode ? NSColor.white : NSColor.black).cgColor
    }

}