//
//  NotifierMenu.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/19/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

class NotifierMenu: NSMenu {

    var menuItems = [String : NSMenuItem]()  // Serial - menuItem
    var batteryVCs = [NSMenuItem : BatteryVC]()

    override init(title aTitle: String) {
        super.init(title: aTitle)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        let quitItem = NSMenuItem(title: "Quit", action: #selector(NotifierMenu.quit(_:)), keyEquivalent: "q")
        quitItem.target = self

        insertItem(quitItem, atIndex: 0)
        insertItem(NSMenuItem.separatorItem(), atIndex: 0)
    }

    func quit(sender: NSMenuItem) {
        exit(1)
    }

    // MARK: battery labels

    func clearDeviceLabels() {
        menuItems.values.forEach { self.removeItem($0) }
        menuItems.removeAll()
    }

    private func setupLabelForDevice(device: Device) {
        let view = NSView(frame: NSRectFromCGRect(CGRectMake(0,0,150,22)))

        // TODO: Dynamic length
        // TODO: Battery not setting maxlevel until shown
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let batteryVC = storyboard.instantiateControllerWithIdentifier("batteryVC") as! BatteryVC
        batteryVC.view.frame = NSRectFromCGRect(CGRectMake(18,0,30,22))
        view.addSubview(batteryVC.view)

        batteryVC.displayedDevice = device

        let textField = NSTextField(frame: NSRectFromCGRect(CGRectMake(18+30+2,0,100,21)))
        textField.backgroundColor = NSColor.clearColor()
        textField.alignment = .Left
        textField.cell?.bezeled = false
        textField.font = NSFont.systemFontOfSize(14.0)

        textField.cell?.title = device.name

        view.addSubview(batteryVC.view)
        view.addSubview(textField)

        let menuItem = NSMenuItem()
        menuItem.view = view

        // TODO: Sorting

        menuItems[device.serialNumber] = menuItem
        batteryVCs[menuItem] = batteryVC

        insertItem(menuItem, atIndex: 0)
    }


    func updateBatteryLabels(devices: [Device]) {
        for device in devices {

            let existingItem = menuItems[device.serialNumber]

            if existingItem == nil {
                setupLabelForDevice(device)
            } else {
                batteryVCs[ menuItems[device.serialNumber]! ]!.displayedDevice = device;
            }
        }
    }
}
