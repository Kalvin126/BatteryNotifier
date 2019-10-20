//
//  SDMMobileDeviceService.h
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 10/14/19.
//  Copyright © 2019 Red Panda. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDMMobileDeviceService : NSObject

+ (nullable NSArray<NSDictionary<NSString*, id>*>*)getDeviceInformation;

@end

NS_ASSUME_NONNULL_END
