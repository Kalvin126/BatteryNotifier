//
//  MainStoryboard.swift
//  BatteryNotifier
//
//  Created by Kalvin Loc on 10/13/19.
//  Copyright © 2019 Red Panda. All rights reserved.
//

import Cocoa

struct MainStoryBoard {

    enum Identifier: String, Identifiable {

        case batteryViewController
        case preferencesController

        var id: String { rawValue }
    }

}

// MARK: - Getting Controllers
extension MainStoryBoard {

    static func instantiateController(with identifier: Identifier) -> Any? {
        return NSStoryboard.mainBoard.instantiateController(withIdentifier: identifier.id)
    }

}
