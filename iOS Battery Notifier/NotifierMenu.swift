//
//  NotifierMenu.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/19/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

final class NotifierMenu: NSMenu {

    private var menuItems = [String : DeviceMenuItem]()  // Serial - menuItem
    var preferenceController: NSWindowController?

    override init(title aTitle: String) {
        super.init(title: aTitle)

        setup()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    private func setup() {
        let listenItem = NSMenuItem(title: "Listening for devices...", action: nil, keyEquivalent: "")
        let prefItem = NSMenuItem(title: "Preferences", action: #selector(clickedPreferences(sender:)), keyEquivalent: "")
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit(sender:)), keyEquivalent: "")

        prefItem.target = self
        quitItem.target = self

        insertItem(quitItem, at: 0)
        insertItem(prefItem, at: 0)
        insertItem(.separator(), at: 0)
        insertItem(listenItem, at: 0)
    }

    @objc func clickedPreferences(sender: NSMenuItem) {
        if preferenceController == nil {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            preferenceController = storyboard.instantiateController(withIdentifier: "preferencesController") as? NSWindowController
            preferenceController?.window?.delegate = self
        }

        preferenceController?.window?.makeKeyAndOrderFront(nil)
    }

    @objc func quit(sender: NSMenuItem) {
        exit(1)
    }

    // MARK: battery labels

    func clearDeviceLabels() {
        while let item = items.first, !item.isSeparatorItem {
            removeItem(item)
        }

        menuItems.removeAll()
    }

    private func setupLabelForDevice(_ device: Device) {
        let deviceItem = DeviceMenuItem(withDevice: device)
        
        menuItems[device.serialNumber] = deviceItem
        insertItem(deviceItem, at: 0)
    }

    func updateBatteryLabels(devices: [Device]) {
        if items.first!.title == "Listening for devices..." {
            removeItem(at: 0)
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
            menuItems.removeValue(forKey: serial)
        }

        if menuItems.count == 0 {
            let listenItem = NSMenuItem(title: "Listening for devices...", action: nil, keyEquivalent: "")
            insertItem(listenItem, at: 0)
        }
    }

}

extension NotifierMenu : NSWindowDelegate {

    func windowWillClose(_ notification: Notification) {
        preferenceController = nil
    }

}
