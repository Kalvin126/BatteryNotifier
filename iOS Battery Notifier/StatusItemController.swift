//
//  StatusItemController.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/15/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

final class StatusItemController: NSObject {

    private var statusItem: NSStatusItem
    private let itemView = NSView()

    private let menu = NotifierMenu(title: "notifierMenu")
    private var batteryViewController: BatteryViewController

    private var isUpdating = false

    // MARK: Init

    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let controller = MainStoryBoard.instantiateController(with: .batteryViewController),
            let batteryController = controller as? BatteryViewController else {
            fatalError(#function + " - Could not instantiate BatteryViewController")
        }

        self.batteryViewController = batteryController

        super.init()

        statusItem.length = 30.0

        batteryViewController.view.frame = statusItem.button!.frame  // This force loads view as well

        statusItem.button?.addSubview(batteryViewController.view, positioned: .above, relativeTo: nil)

        statusItem.highlightMode = true
        statusItem.menu = menu
    }

}

// MARK: - Actions
extension StatusItemController {
}

// MARK: - DeviceManagerDelegate
extension StatusItemController: DeviceObserver {

    func deviceManager(_ manager: DeviceManager, didFetch devices: Set<Device>) {
        guard let lowestCapacityDevice = devices.lowestCapacityDevice else {
            return
        }
        let displayedDevice = self.batteryViewController.displayedDevice

        var updateDisplayDevice = false

        if let displayedDevice = displayedDevice,
            displayedDevice.currentBatteryCapacity > lowestCapacityDevice.currentBatteryCapacity ||
                displayedDevice == lowestCapacityDevice ||
                devices.contains(displayedDevice) {
            updateDisplayDevice = true
        }

        if updateDisplayDevice {
            self.batteryViewController.displayedDevice = lowestCapacityDevice
        }

        self.menu.updateBatteryLabels(devices: devices)
    }

    func deviceManager(_ manager: DeviceManager, didExpire device: Device) {
        if batteryViewController.displayedDevice?.serialNumber == device.serialNumber {
            let newLowestCapacityDevice = manager.devices.values.lowestCapacityDevice
            batteryViewController.displayedDevice = newLowestCapacityDevice
        }

        menu.invalidateDeviceItem(serial: device.serialNumber)
    }

}
