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

    var maxLevelWidth: CGFloat = 0

    var defaultColor = NSColor.darkGrayColor().CGColor {
        didSet {
            if enabled {
                nub.layer?.backgroundColor   = defaultColor
                body.layer?.borderColor      = defaultColor

                if !charging {
                    level.layer?.backgroundColor = defaultColor
                }
            }
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
            fillLevelByPercent(0) // TODO: Not a great place to to initial setting
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
        levelOffsetConstraint.constant = (maxLevelWidth*(CGFloat(100 - percent)/100.0)) + 2.0

        if !charging {
            setLevelColorForPercent(percent)
        }
    }

    private func setLevelColorForPercent(percent: Int) {
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