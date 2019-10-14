//
//  StatusItemController.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/15/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

class StatusItemController : NSObject {

    private var statusItem: NSStatusItem
    private let itemView = NSView()

    private let menu = NotifierMenu(title: "notifierMenu")
    private var batteryVC: BatteryVC

    private var updating = false

    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        batteryVC = storyboard.instantiateController(withIdentifier: "batteryVC") as! BatteryVC

        super.init()

        statusItem.length = 30.0

        batteryVC.view.frame = statusItem.button!.frame  // This force loads view as well

        statusItem.button?.addSubview(batteryVC.view, positioned: .above, relativeTo: nil)

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

            let displayedDevice = self.batteryVC.displayedDevice
            if  displayedDevice == nil ||
                displayedDevice!.batteryCapacity > lowestDevice.batteryCapacity ||
                displayedDevice! == lowestDevice ||
                devices.contains(displayedDevice!)
            {
                updateDisplayDevice = true
            }

            DispatchQueue.main.async {
                if updateDisplayDevice {
                    self.batteryVC.displayedDevice = lowestDevice
                }
                self.menu.updateBatteryLabels(devices: devices)
            }

            self.updating = false
        }
    }

    func startMonitoring() {
        NSLog("StatusItemController: Listening for iOS devices...")

        let darwinNotificationCenter = DarwinNotificationsManager.sharedInstance()
        darwinNotificationCenter?.register(forNotificationName: "SDMMD_USBMuxListenerDeviceAttachedNotification") {
            print("Recieved SDMMD_USBMuxListenerDeviceAttachedNotification")
            if !(self.updating) {
                self.updateBatteryViews()
            }
        }
    }
}

extension StatusItemController: DeviceManagerDelegate {

    func expirationMetForDevice(serial: String) {
        if batteryVC.displayedDevice?.serialNumber == serial {
            let sortedDevices = DeviceManager.getAllDevices()
                .sorted { $0.batteryCapacity < $1.batteryCapacity }
            batteryVC.displayedDevice = sortedDevices.first
        }

        menu.invalidateDeviceItem(serial: serial)
    }

}
