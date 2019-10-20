//
//  SDMMobileDeviceService.m
//  BatteryNotifier
//
//  Created by Kalvin Loc on 10/14/19.
//  Copyright © 2019 Red Panda. All rights reserved.
//

#import "SDMMobileDeviceService.h"
@import Foundation;
@import SDMMobileDevice;

@implementation SDMMobileDeviceService

+ (nullable NSArray<NSDictionary<NSString*, id>*>*)getDeviceInformation {
    NSMutableArray<NSDictionary*>* returnInfo = [NSMutableArray array];

    NSArray* deviceList = (__bridge NSArray*)SDMMD_AMDCreateDeviceList();

    for (id amDevice in deviceList) {
        SDMMD_AMDeviceRef device = (__bridge SDMMD_AMDeviceRef)(amDevice);

        NSDictionary* information = [self getDeviceInformation:device];

        if (information == nil) continue;

        [returnInfo addObject:information];
    }

    return ([returnInfo count] == 0 ? nil : returnInfo);
}

+ (nullable NSDictionary*)getDeviceInformation:(SDMMD_AMDeviceRef)device {
    sdmmd_return_t status;

    status = SDMMD_AMDeviceConnect(device);

    if (status != kAMDSuccess) return nil;
    
    status = SDMMD_AMDeviceStartSession(device);

    if (status != kAMDSuccess) return nil;

    NSString* name = (__bridge NSString*)[self getValueForKey:@kDeviceName
                                                     inDomain:@"NULL"
                                                   fromDevice:device];
    NSString* serialNumber = (__bridge NSString*)[self getValueForKey:@kSerialNumber
                                                             inDomain:@"NULL"
                                                           fromDevice:device];

    NSString* deviceClass = (__bridge NSString*)[self getValueForKey:@kDeviceClass
                                                            inDomain:@"NULL"
                                                          fromDevice:device];

    BOOL isBatteryCharging = CFBooleanGetValue([self getValueForKey:@kBatteryIsCharging
                                                           inDomain:@kBatteryDomain
                                                         fromDevice:device]);
    NSNumber* batteryCapacity = (__bridge NSNumber*)[self getValueForKey:@kBatteryCurrentCapacity inDomain:@kBatteryDomain fromDevice:device];

    SDMMD_AMDeviceStopSession(device);
    SDMMD_AMDeviceDisconnect(device);

    return [NSDictionary dictionaryWithObjectsAndKeys:
            name, @"name",
            serialNumber, @"serialNumber",
            deviceClass, @"deviceClass",
            [NSNumber numberWithBool:isBatteryCharging], @"isBatteryCharging",
            batteryCapacity, @"batteryCapacity",
            nil];;
}

+ (CFTypeRef)getValueForKey:(NSString*)key
                   inDomain:(NSString*)domain
                 fromDevice:(SDMMD_AMDeviceRef)device {
    CFStringRef domainRef = (__bridge CFStringRef)domain;
    CFStringRef keyRef = (__bridge CFStringRef)key;

    return SDMMD_AMDeviceCopyValue(device, domainRef, keyRef);
}

@end
