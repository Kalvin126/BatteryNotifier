//
//  DarwinNotificationsManager.h
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/22/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef DarwinNotifications_h
#define DarwinNotifications_h

@interface DarwinNotificationsManager : NSObject

@property (strong, nonatomic) id someProperty;

+ (instancetype)sharedInstance;

- (void)registerForNotificationName:(NSString *)name callback:(void (^)(void))callback;
- (void)postNotificationWithName:(NSString *)name;

@end

#endif

/*
 http://stackoverflow.com/questions/26637023/how-to-properly-use-cfnotificationcenteraddobserver-in-swift-for-ios
*/