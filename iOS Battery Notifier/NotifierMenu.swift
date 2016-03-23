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
        let deviceItem = DeviceMenuItem(withDevice: device)

        // TODO: Sorting

        menuItems[device.serialNumber] = deviceItem
        insertItem(deviceItem, atIndex: 0)
    }

    func updateBatteryLabels(devices: [Device]) {
        devices.forEach {
            if let item = menuItems[$0.serialNumber] {
                item.updateWithDevice($0)
            } else {
                setupLabelForDevice($0)
            }
        }
    }

}
