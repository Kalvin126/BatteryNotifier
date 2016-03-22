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

    // TODO: Dynamic length
    
    init(withDevice device: Device) {
        super.init()

        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        batteryVC = storyboard.instantiateControllerWithIdentifier("batteryVC") as? BatteryVC

        batteryVC!.view.frame = NSRectFromCGRect(CGRectMake(18,0,30,22))

        let deviceView = NSView(frame: NSRectFromCGRect(CGRectMake(0,0,175,22)))

        textField.frame = NSRectFromCGRect(CGRectMake(18+30+2,0,125,21))
        textField.backgroundColor = NSColor.clearColor()
        textField.font = NSFont.systemFontOfSize(14.0)
        textField.alignment = .Left
        textField.cell?.bezeled = false
        textField.selectable = false

        deviceView.addSubview(batteryVC!.view)
        deviceView.addSubview(textField)
        view = deviceView

        updateWithDevice(device)
    }

    override init(title aString: String, action aSelector: Selector, keyEquivalent charCode: String) {
        super.init(title: aString, action: aSelector, keyEquivalent: charCode)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Should not ever be invoked
    }

    func updateWithDevice(device: Device) {
        batteryVC!.displayedDevice = device
        textField.cell?.title = device.name
    }
}
