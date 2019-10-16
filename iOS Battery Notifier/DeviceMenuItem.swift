//
//  DeviceMenuItem.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/22/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

final class DeviceMenuItem: NSMenuItem {

    // MARK: Children

    private var batteryViewController: BatteryViewController?
    private var textField = NSTextField()

    // MARK: Init

    init(device: Device) {
        super.init(title: "", action: nil, keyEquivalent: "")

        guard let batteryViewController = MainStoryBoard.instantiateController(with: .batteryViewController) as? BatteryViewController else {
            fatalError(#function + " - Could not instantiate BatteryViewController")
        }

        self.batteryViewController = batteryViewController

        let pad: CGFloat = 18.0
        let spacing: CGFloat = 2.0
        batteryViewController.view.frame = NSMakeRect(pad,0,30,22)

        textField.frame = NSMakeRect(pad+batteryViewController.view.frame.size.width+spacing,3,125,21)
        textField.backgroundColor = NSColor.clear
        textField.font = NSFont.systemFont(ofSize: 14.0)
        textField.alignment = .left
        textField.cell?.isBezeled = false
        textField.isSelectable = false

        let deviceView = NSView(frame: NSMakeRect(0,0,155,22))
        deviceView.addSubview(batteryViewController.view)
        deviceView.addSubview(textField)
        view = deviceView

        updateWithDevice(device)

        UserDefaults.standard.addObserver(self, forKeyPath: ConfigKey.showMenuPercentage.id, options: .new, context: nil)
    }

    override init(title aString: String, action aSelector: Selector?, keyEquivalent charCode: String) {
        super.init(title: aString, action: aSelector, keyEquivalent: charCode)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)

        // Should not ever be invoked
    }

    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: ConfigKey.showMenuPercentage.id)
    }

    // MARK: NSKeyValueObserving

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == ConfigKey.showMenuPercentage.id {
            setItemText()
        }
    }

}

// MARK: - Actions
extension DeviceMenuItem {

    func updateWithDevice(_ device: Device) {
        batteryViewController?.displayedDevice = device

        setItemText()
    }

    func setItemText() {
        let userDefaults = UserDefaults.standard
        let device = batteryViewController!.displayedDevice!
        var textString = device.name

        let showPercentage = userDefaults.bool(forKey: .showMenuPercentage)
        if showPercentage {
            let digits = device.currentBatteryCapacity.description.map{ Int(String($0)) ?? 0 }
            let padding = String(repeating: " ", count: 2*(3-digits.count))
            let percentString = "\(padding)\(device.currentBatteryCapacity)% "

            textString = percentString + textString
        }

        textField.cell?.title = textString
        textField.sizeToFit()

        let deviceViewWidth = textField.frame.origin.x + textField.frame.size.width + 18

        view?.frame = NSMakeRect(0,0,deviceViewWidth,22)
    }

}
