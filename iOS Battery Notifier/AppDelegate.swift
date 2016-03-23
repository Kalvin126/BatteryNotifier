//
//  AppDelegate.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/15/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa
import SDMMobileDevice

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItemController = StatusItemController()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        InitializeSDMMobileDevice()
        statusItemController.startMonitoring()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}
