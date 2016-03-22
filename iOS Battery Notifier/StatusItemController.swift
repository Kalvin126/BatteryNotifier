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

    private var callbackTimer: NSTimer?

    var monitoring: Bool {
        return (callbackTimer == nil)
    }

    private var fetching = false;

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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.fetching = true
            let devices = DeviceManager.refreshDevices()
            self.fetching = false

            dispatch_async(dispatch_get_main_queue()) {
                if devices.count == 0 {
                    self.batteryVC.displayedDevice = nil
                } else {
                    var lowestPercentageDevice: Device = devices[0]

                    for device in devices {
                        if device.batteryCapacity < lowestPercentageDevice.batteryCapacity {
                            lowestPercentageDevice = device
                        }
                    }

                    self.batteryVC.displayedDevice = lowestPercentageDevice
                }

                self.menu.updateBatteryLabels(devices)
            }
        }
    }

    func startMonitoring() {
        updateBatteryViews()

        callbackTimer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: #selector(StatusItemController.updateTimerCallback(_:)), userInfo: nil, repeats: true)


//        let notif = "SDMMD_USBMuxListenerDeviceAttachedNotificationFinished"
//        CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), UnsafePointer<Void>(self), updateTimerCallback(_:), notif, nil, .DeliverImmediately)
    }

    func stopMonitoring() {
        callbackTimer?.invalidate()
        callbackTimer = nil

//        let notif = "SDMMD_USBMuxListenerDeviceAttachedNotificationFinished"
//        CFNotificationCenterRemoveObserver(CFNotificationCenterGetLocalCenter(), UnsafePointer<Void>(self), notif, nil)
    }

    func updateTimerCallback(sender: NSTimer) {
        if !fetching {
            print("Fetching devices...")
            updateBatteryViews()
        }
    }
}
