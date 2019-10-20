//
//  DeviceService.swift
//  BatteryNotifier
//
//  Created by Kalvin Loc on 10/19/19.
//  Copyright © 2019 Red Panda. All rights reserved.
//

import Foundation

protocol DeviceService {

    func getAttachedDevices() -> Set<Device>?

}
