//
//  DeviceMenuItem.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/22/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

class DeviceMenuItem: NSMenuItem {

    private var batteryVC: BatteryVC?
    private var textField = NSTextField()

    init(withDevice device: Device) {
        super.init(title: "", action: nil, keyEquivalent: "")

        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        batteryVC = storyboard.instantiateController(withIdentifier: "batteryVC") as? BatteryVC

        let pad: CGFloat = 18.0
        let spacing: CGFloat = 2.0
        batteryVC!.view.frame = NSMakeRect(pad,0,30,22)

        textField.frame = NSMakeRect(pad+batteryVC!.view.frame.size.width+spacing,3,125,21)
        textField.backgroundColor = NSColor.clear
        textField.font = NSFont.systemFont(ofSize: 14.0)
        textField.alignment = .left
        textField.cell?.isBezeled = false
        textField.isSelectable = false

        let deviceView = NSView(frame: NSMakeRect(0,0,155,22))
        deviceView.addSubview(batteryVC!.view)
        deviceView.addSubview(textField)
        view = deviceView

        updateWithDevice(device)

        UserDefaults.standard.addObserver(self, forKeyPath: "ShowMenuPercentage", options: .new, context: nil)
    }

    override init(title aString: String, action aSelector: Selector?, keyEquivalent charCode: String) {
        super.init(title: aString, action: aSelector, keyEquivalent: charCode)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)

        // Should not ever be invoked
    }

    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: "ShowMenuPercentage")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "ShowMenuPercentage" {
            setItemText()
        }
    }

    func updateWithDevice(_ device: Device) {
        batteryVC!.displayedDevice = device

        setItemText()
    }

    func setItemText() {
        let userDefaults = UserDefaults.standard
        let device = batteryVC!.displayedDevice!
        var textString = device.name

        let showPercentage = userDefaults.bool(forKey: "ShowMenuPercentage")
        if showPercentage {
            let digits = device.batteryCapacity.description.map{ Int(String($0)) ?? 0 }
            let padding = String(repeating: " ", count: 2*(3-digits.count))
            let percentString = "\(padding)\(device.batteryCapacity)% "

            textString = percentString + textString
        }

        textField.cell?.title = textString
        textField.sizeToFit()

        let deviceViewWidth = textField.frame.origin.x + textField.frame.size.width + 18

        view?.frame = NSMakeRect(0,0,deviceViewWidth,22)
    }
}
