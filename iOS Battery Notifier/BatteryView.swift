//
//  BatteryView.swift
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/18/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

import Cocoa

final class BatteryView: NSView {

    static var lowChargeColor: NSColor { .red }
    static var mediumChargeColor: NSColor { .yellow }
    static var chargingColor: NSColor { .green }

    var batteryLevel = 0 {
        didSet {
            // needs layout to set level width
            needsLayout = true
        }
    }

    var defaultColor: NSColor = .darkGray {
        didSet {
            nub.layer?.backgroundColor   = defaultColor.cgColor
            body.layer?.borderColor      = defaultColor.cgColor

            setLevelColor(by: batteryLevel)
        }
    }

    var isCharging = false {
        didSet {
            level.layer?.backgroundColor = (isCharging ? Self.chargingColor : defaultColor).cgColor
        }
    }

    // MARK: Subviews

    @IBOutlet weak var nub: NSView!
    @IBOutlet weak var body: NSView!
    @IBOutlet weak var level: NSView!

    @IBOutlet weak var levelOffsetConstraint: NSLayoutConstraint!

    // MARK: Init

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        wantsLayer = true
    }

    // MARK: NSView

    override func layout() {
        super.layout()

        let maxLevelWidth = body.frame.width - (2.0*2)
        levelOffsetConstraint.constant = (maxLevelWidth*(CGFloat(100 - batteryLevel)/100.0)) + 2.0
    }

}

// MARK: - Actions
extension BatteryView {

    func setup() {
        body.layer?.borderWidth = 1.0

        nub.layer?.cornerRadius   = 2.5
        body.layer?.cornerRadius  = 2.5

        nub.layer?.backgroundColor   = defaultColor.cgColor
        body.layer?.borderColor      = defaultColor.cgColor
        level.layer?.backgroundColor = defaultColor.cgColor
    }

    func fillLevel(by percent: Int) {
        // changing level width to be done at layout time
        batteryLevel = percent

        setLevelColor(by: percent)
    }

    private func setLevelColor(by percent: Int) {
        guard !isCharging else { return }

        let color: NSColor = {
            switch percent {
            case 1...20:    return Self.lowChargeColor
            case 21...50:   return Self.mediumChargeColor
            default:        return defaultColor
            }
        }()

        level.layer?.backgroundColor = color.cgColor
    }

}
