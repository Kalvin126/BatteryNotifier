//
//  StatusItemController.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/15/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

final class StatusItemController : NSObject {

    private var statusItem: NSStatusItem
    private let itemView = NSView()

    private let menu = NotifierMenu(title: "notifierMenu")
    private var batteryViewController: BatteryViewController

    private var updating = false

    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        batteryViewController = storyboard.instantiateController(withIdentifier: "BatteryViewController") as! BatteryViewController

        super.init()

        statusItem.length = 30.0

        batteryViewController.view.frame = statusItem.button!.frame  // This force loads view as well

        statusItem.button?.addSubview(batteryViewController.view, positioned: .above, relativeTo: nil)

        statusItem.highlightMode = true
        statusItem.menu = menu
    }

    private func updateBatteryViews() {
        updating = true

        DispatchQueue.global(qos: .default).async {
            let devices = DeviceManager.refreshDevices()
            guard devices.count > 0 else { self.updating = false; return }

            let lowestDevice = devices.sorted { $0.batteryCapacity < $1.batteryCapacity }.first!
            var updateDisplayDevice = false

            let displayedDevice = self.batteryViewController.displayedDevice
            if  displayedDevice == nil ||
                displayedDevice!.batteryCapacity > lowestDevice.batteryCapacity ||
                displayedDevice! == lowestDevice ||
                devices.contains(displayedDevice!)
            {
                updateDisplayDevice = true
            }

            DispatchQueue.main.async {
                if updateDisplayDevice {
                    self.batteryViewController.displayedDevice = lowestDevice
                }
                self.menu.updateBatteryLabels(devices: devices)
            }

            self.updating = false
        }
    }

    func startMonitoring() {
        NSLog("StatusItemController: Listening for iOS devices...")

        DarwinNotificationsManager.default
            .observeNotification(forName: "SDMMD_USBMuxListenerDeviceAttachedNotification") {
                print("Recieved SDMMD_USBMuxListenerDeviceAttachedNotification")

                if !(self.updating) {
                    self.updateBatteryViews()
                }
        }
    }
}

// MARK - DeviceManagerDelegate
extension StatusItemController: DeviceManagerDelegate {

    func deviceManager(_ manager: DeviceManager, expirationMetForDeviceWith serial: String) {
        if batteryViewController.displayedDevice?.serialNumber == serial {
            let sortedDevices = DeviceManager.getAllDevices()
                .sorted { $0.batteryCapacity < $1.batteryCapacity }
            batteryViewController.displayedDevice = sortedDevices.first
        }

        menu.invalidateDeviceItem(serial: serial)
    }

}
