//
//  BatteryVC.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/18/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

class BatteryVC: NSViewController {

    @IBOutlet var batteryView: BatteryView!

    var enabled = false {
        didSet {
            if enabled != oldValue {
                batteryView.enabled = enabled
            }
        }
    }

    var displayedDevice: Device? {
        didSet {
            if let device = displayedDevice {
                batteryView.charging = device.batteryCharging
                updateLevelWithPercent(device.batteryCapacity)
            }

            enabled = (displayedDevice != nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        batteryView.setup()
    }

    override func viewDidLayout() {
        super.viewDidLayout()
    }

    private func updateLevelWithPercent(percent: Int) {
        batteryView.fillLevelByPercent(percent)
    }
}
