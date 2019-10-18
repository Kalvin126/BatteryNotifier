//
//  ListRowViewController.swift
//  BatteryNotifier Widget
//
//  Created by Kalvin Loc on 3/24/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

final class ListRowViewController: NSViewController {

    // MARK: Children

    @IBOutlet private var deviceImageView: NSImageView!
    @IBOutlet private var nameField: NSTextField!
    @IBOutlet private var batteryLevelField: NSTextField!
    @IBOutlet private var batteryView: NSView!

    private var batteryViewController: BatteryViewController?

    // MARK: NSViewController

    override var nibName: String? { "ListRowViewController" }

    override func loadView() {
        super.loadView()

        guard let controller = MainStoryBoard.instantiateController(with: .batteryViewController) as? BatteryViewController else {
            fatalError(#function + " - Could not instantiate BatteryViewController")
        }

        batteryViewController = controller

        batteryView.addSubview(batteryViewController!.view, positioned: .above, relativeTo: nil)

        guard let dictionary = representedObject as? [String : AnyObject],
            let device = Device(dictionary: dictionary) else { return }


        let image = NSImage(named: device.deviceClass) ?? NSImage(named: "iPhone")
        deviceImageView.image = image
        nameField.cell?.title = device.name

        batteryLevelField.cell?.title = "\(device.currentBatteryCapacity)%"

        batteryViewController?.displayedDevice = device
        batteryViewController?.whiteThemeOnly = true
    }

    override func viewDidLayout() {
        super.viewDidLayout()

        var battFrame = batteryView.frame
        battFrame.origin = .zero
        batteryViewController!.view.frame = battFrame
    }

}
