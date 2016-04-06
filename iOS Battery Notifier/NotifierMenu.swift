//
//  NotifierMenu.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/19/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

class NotifierMenu: NSMenu {

    private var menuItems = [String : DeviceMenuItem]()  // Serial - menuItem
    var preferenceController: NSWindowController?

    override init(title aTitle: String) {
        super.init(title: aTitle)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        let listenItem = NSMenuItem(title: "Listening for devices...", action: nil, keyEquivalent: "")
        let prefItem = NSMenuItem(title: "Preferences", action: #selector(clickedPreferences(_:)), keyEquivalent: "")
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit(_:)), keyEquivalent: "")

        prefItem.target = self
        quitItem.target = self

        insertItem(quitItem, atIndex: 0)
        insertItem(prefItem, atIndex: 0)
        insertItem(NSMenuItem.separatorItem(), atIndex: 0)
        insertItem(listenItem, atIndex: 0)
    }

    func clickedPreferences(sender: NSMenuItem) {
        if preferenceController == nil {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            preferenceController = storyboard.instantiateControllerWithIdentifier("preferencesController") as? NSWindowController
            preferenceController?.window?.delegate = self
        }

        preferenceController?.window?.makeKeyAndOrderFront(nil)
    }

    func quit(sender: NSMenuItem) {
        exit(1)
    }

    // MARK: battery labels

    func clearDeviceLabels() {
        while let item = itemArray.first where !(item.separatorItem) {
            removeItem(item)
        }

        menuItems.removeAll()
    }

    private func setupLabelForDevice(device: Device) {
        let deviceItem = DeviceMenuItem(withDevice: device)
        
        menuItems[device.serialNumber] = deviceItem
        insertItem(deviceItem, atIndex: 0)
    }

    func updateBatteryLabels(devices: [Device]) {
        if itemArray.first!.title == "Listening for devices..." {
            removeItemAtIndex(0)
        }

        devices.forEach {
            if let item = menuItems[$0.serialNumber] {
                item.updateWithDevice($0)
            } else {
                setupLabelForDevice($0)
            }
        }
    }

    func invalidateDeviceItem(serial: String) {
        if let item = menuItems[serial] {
            removeItem(item)
            menuItems.removeValueForKey(serial)
        }

        if menuItems.count == 0 {
            let listenItem = NSMenuItem(title: "Listening for devices...", action: nil, keyEquivalent: "")
            insertItem(listenItem, atIndex: 0)
        }
    }

}

extension NotifierMenu : NSWindowDelegate {

    func windowWillClose(notification: NSNotification) {
        preferenceController = nil
    }

}
