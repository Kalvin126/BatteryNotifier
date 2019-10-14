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
    private var preferenceController: NSWindowController?

    // MARK: Text

    private static var listeningForDevicesText: String { "Listening for devices..." }
    private static var preferencesTitle: String { "Preferences" }
    private static var quitTitle: String { "Quit" }

    // MARK: Init

    override init(title aTitle: String) {
        super.init(title: aTitle)

        setup()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

}

// MARK: - Actions
extension NotifierMenu {

    private func setup() {
        let listenItem = NSMenuItem(title: Self.listeningForDevicesText, action: nil, keyEquivalent: "")
        let prefItem = NSMenuItem(title: Self.preferencesTitle, action: #selector(clickedPreferences(sender:)), keyEquivalent: "")
        let quitItem = NSMenuItem(title: Self.quitTitle, action: #selector(quit(sender:)), keyEquivalent: "")

        prefItem.target = self
        quitItem.target = self

        insertItem(quitItem, at: 0)
        insertItem(prefItem, at: 0)
        insertItem(.separator(), at: 0)
        insertItem(listenItem, at: 0)
    }

    // MARK: Battery Labels

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
        if let firstMenuItem = items.first,
            firstMenuItem.title == Self.listeningForDevicesText {
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

        if menuItems.isEmpty {
            let listenItem = NSMenuItem(title: Self.listeningForDevicesText, action: nil, keyEquivalent: "")
            insertItem(listenItem, at: 0)
        }
    }

}

// MARK: - Events
extension NotifierMenu {

    @objc func clickedPreferences(sender: NSMenuItem) {
        if preferenceController == nil {
            guard let controller = MainStoryBoard.instantiateController(with: .batteryViewController) as? NSWindowController else {
                fatalError(#function + " - Could not instantiate PreferenceViewController")
            }

            controller.window?.delegate = self
        }

        preferenceController?.window?.makeKeyAndOrderFront(nil)
    }

    @objc func quit(sender: NSMenuItem) {
        exit(1)
    }

}

// MARK: - NSWindowDelegate
extension NotifierMenu: NSWindowDelegate {

    func windowWillClose(_ notification: Notification) {
        preferenceController = nil
    }

}
