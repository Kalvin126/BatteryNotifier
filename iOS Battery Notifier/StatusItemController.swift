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
            guard devices.count > 0 else { self.updating = false; return }

            let lowestDevice = (devices.sort{ $0.batteryCapacity < $1.batteryCapacity })[0]

            dispatch_async(dispatch_get_main_queue()) {
                if  self.batteryVC.displayedDevice == nil || lowestDevice.batteryCapacity < self.batteryVC.displayedDevice!.batteryCapacity {
                    self.batteryVC.displayedDevice = lowestDevice
                }
                self.menu.updateBatteryLabels(devices)
            }

            self.updating = false
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
