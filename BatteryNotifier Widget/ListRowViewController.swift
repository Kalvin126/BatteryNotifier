//
//  ListRowViewController.swift
//  BatteryNotifier Widget
//
//  Created by Kalvin Loc on 3/24/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

class ListRowViewController: NSViewController {

    @IBOutlet weak var deviceImageView: NSImageView!
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var batteryLevelField: NSTextField!
    @IBOutlet weak var batteryView: NSView!

    private var batteryVC: BatteryVC?
    
    override var nibName: String? {
        return "ListRowViewController"
    }

    override func loadView() {
        super.loadView()

        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        batteryVC = storyboard.instantiateControllerWithIdentifier("batteryVC") as? BatteryVC
        batteryView.addSubview(batteryVC!.view, positioned: .Above, relativeTo: nil)

        let device = Device(withDictionary: representedObject as! [String : AnyObject])

        let image = NSImage(named: device.deviceClass) ?? NSImage(named: "iPhone")
        deviceImageView.image = image
        nameField.cell?.title = device.name
        batteryLevelField.cell?.title = "\(device.batteryCapacity)%"
        batteryVC?.displayedDevice = device
    }

    override func viewDidLayout() {
        super.viewDidLayout()

        var battFrame = batteryView.frame
        battFrame.origin = CGPointZero
        batteryVC!.view.frame = battFrame
    }

}
