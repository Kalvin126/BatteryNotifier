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
        super.init()

        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        batteryVC = storyboard.instantiateControllerWithIdentifier("batteryVC") as? BatteryVC

        let pad: CGFloat = 18.0
        let spacing: CGFloat = 2.0
        batteryVC!.view.frame = NSMakeRect(pad,0,30,22)

        textField.frame = NSMakeRect(pad+batteryVC!.view.frame.size.width+spacing,3,125,21)
        textField.backgroundColor = NSColor.clearColor()
        textField.font = NSFont.systemFontOfSize(14.0)
        textField.alignment = .Left
        textField.cell?.bezeled = false
        textField.selectable = false

        let deviceView = NSView(frame: NSMakeRect(0,0,155,22))
        deviceView.addSubview(batteryVC!.view)
        deviceView.addSubview(textField)
        view = deviceView

        updateWithDevice(device)

        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: "ShowMenuPercentage", options: .New, context: nil)
    }

    override init(title aString: String, action aSelector: Selector, keyEquivalent charCode: String) {
        super.init(title: aString, action: aSelector, keyEquivalent: charCode)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Should not ever be invoked
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "ShowMenuPercentage" {
            setItemText()
        }
    }

    func updateWithDevice(device: Device) {
        batteryVC!.displayedDevice = device

        setItemText()
    }

    func setItemText() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let device = batteryVC!.displayedDevice!
        var textString = device.name

        let showPercentage = userDefaults.boolForKey("ShowMenuPercentage")
        if showPercentage {
            let digits = device.batteryCapacity.description.characters.map{ Int(String($0)) ?? 0 }
            let padding = String(count: 2*(3-digits.count), repeatedValue: " " as Character)
            let percentString = "\(padding)\(device.batteryCapacity)% "

            textString = percentString + textString
        }

        textField.cell?.title = textString
        textField.sizeToFit()

        let deviceViewWidth = textField.frame.origin.x + textField.frame.size.width + 18

        view?.frame = NSMakeRect(0,0,deviceViewWidth,22)
    }
}
