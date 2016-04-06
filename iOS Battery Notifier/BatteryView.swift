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

    var batteryLevel = 0 {
        didSet {
            // needs layout to set level width
            needsLayout = true
        }
    }

    var defaultColor = NSColor.darkGrayColor().CGColor {
        didSet {
            nub.layer?.backgroundColor   = defaultColor
            body.layer?.borderColor      = defaultColor

            setLevelColorForPercent(batteryLevel)
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
    }

    override func layout() {
        super.layout()

        let maxLevelWidth = body.frame.width - (2.0*2)
        levelOffsetConstraint.constant = (maxLevelWidth*(CGFloat(100 - batteryLevel)/100.0)) + 2.0
    }

    func setup() {
        body.layer?.borderWidth = 1.0

        nub.layer?.cornerRadius   = 2.5
        body.layer?.cornerRadius  = 2.5

        nub.layer?.backgroundColor   = NSColor.darkGrayColor().CGColor
        body.layer?.borderColor      = NSColor.darkGrayColor().CGColor
        level.layer?.backgroundColor = NSColor.darkGrayColor().CGColor
    }

    func fillLevelByPercent(percent: Int) {
        // changing level width to be done at layout time
        batteryLevel = percent

        setLevelColorForPercent(percent)
    }

    private func setLevelColorForPercent(percent: Int) {
        guard !charging else { return }

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