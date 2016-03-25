//
//  BatteryView.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/18/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

class BatteryView : NSView {

    @IBOutlet weak var nub: NSView!
    @IBOutlet weak var body: NSView!
    @IBOutlet weak var level: NSView!

    @IBOutlet weak var levelOffsetConstraint: NSLayoutConstraint!

    private var maxLevelWidth: CGFloat = 0
    var batteryLevel = 0

    var defaultColor = NSColor.darkGrayColor().CGColor {
        didSet {
            nub.layer?.backgroundColor   = defaultColor
            body.layer?.borderColor      = defaultColor
        }
    }

    var enabled = false {
        didSet {
            if enabled != oldValue {
                if enabled {
                    setTheme(nil)
                } else {
                    defaultColor = NSColor.darkGrayColor().CGColor
                }
            }
        }
    }

    var charging = false {
        didSet {
            level.layer?.backgroundColor = (charging ? NSColor.greenColor().CGColor : defaultColor)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        wantsLayer = true

        // Status bar theme change
        let center = NSDistributedNotificationCenter.defaultCenter()
        let notif = "AppleInterfaceThemeChangedNotification"
        center.addObserver(self, selector: #selector(BatteryView.setTheme(_:)), name: notif, object: nil)
    }

    deinit {
        let center = NSDistributedNotificationCenter.defaultCenter()
        center.removeObserver(self, name: "AppleInterfaceThemeChangedNotification", object: nil)
    }

    override func layout() {
        super.layout()

        if maxLevelWidth == 0 {
            maxLevelWidth = level.frame.width
            fillLevelByPercent(batteryLevel)
        }
    }

    func setup() {
        setTheme(nil)

        body.layer?.borderWidth = 1.0

        nub.layer?.cornerRadius   = 2.5
        body.layer?.cornerRadius  = 2.5

        nub.layer?.backgroundColor   = NSColor.darkGrayColor().CGColor
        body.layer?.borderColor      = NSColor.darkGrayColor().CGColor
        level.layer?.backgroundColor = NSColor.darkGrayColor().CGColor
    }

    func setTheme(notification: NSNotification?) {
        let darkMode = NSUserDefaults.standardUserDefaults().stringForKey("AppleInterfaceStyle") == "Dark"
        defaultColor = (darkMode ? NSColor.whiteColor() : NSColor.blackColor()).CGColor
    }

    func fillLevelByPercent(percent: Int) {
        batteryLevel = percent
        levelOffsetConstraint.constant = (maxLevelWidth*(CGFloat(100 - percent)/100.0)) + 2.0

        setLevelColorForPercent(percent)
    }

    private func setLevelColorForPercent(percent: Int) {
        if charging { return }

        var color: CGColor

        switch percent {
        case 1...20:
            color = NSColor.redColor().CGColor
        case 21...50:
            color = NSColor.yellowColor().CGColor
        default:
            color = defaultColor
        }

        level.layer?.backgroundColor = color
    }
}