//
//  SDMMobileDeviceService.swift
//  BatteryNotifier
//
//  Created by Kalvin Loc on 10/19/19.
//  Copyright © 2019 Red Panda. All rights reserved.
//

import Foundation

// MARK: - DeviceService
extension SDMMobileDeviceService: DeviceService {

    func getAttachedDevices() -> Set<Device>? {
        guard let information = Self.getDeviceInformation() else { return nil }

        return Set(information.compactMap(Device.init))
    }

}
