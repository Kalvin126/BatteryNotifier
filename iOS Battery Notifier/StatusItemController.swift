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
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)

        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        batteryVC = storyboard.instantiateControllerWithIdentifier("batteryVC") as! BatteryVC

        super.init()

        statusItem.length = 30.0

        batteryVC.view.frame = statusItem.button!.frame  // This force loads view as well

        statusItem.button?.addSubview(batteryVC.view, positioned: .Above, relativeTo: nil)

        statusItem.highlightMode = true
        statusItem.menu = menu
    }

    private func updateBatteryViews() {
        updating = true
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let devices = DeviceManager.refreshDevices()

            if devices.count > 0 {
                let lowestPercentageDevice = (devices.sort{ $0.batteryCapacity < $1.batteryCapacity })[0]
                var updateDeviceView = self.batteryVC.displayedDevice == nil

                if self.batteryVC.displayedDevice == lowestPercentageDevice {   // lowestPercentageDevice is already the current displayDevice
                    updateDeviceView = true
                } else {    // new lowestPercentageDevie
                    if let battVC = self.batteryVC.displayedDevice {
                        updateDeviceView = (battVC.batteryCapacity > lowestPercentageDevice.batteryCapacity)
                    }
                }

                if updateDeviceView {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.updating = false
                        self.batteryVC.displayedDevice = lowestPercentageDevice
                        self.menu.updateBatteryLabels(devices)
                    }
                }
            }
        }
    }

    func startMonitoring() {
        NSLog("StatusItemController: Listening for iOS devices...")

        let darwinNotificationCenter = DarwinNotificationsManager.sharedInstance()
        darwinNotificationCenter.registerForNotificationName("SDMMD_USBMuxListenerDeviceAttachedNotification"){
            if !(self.updating) {
                self.updateBatteryViews()
            }
        }
    }
}
