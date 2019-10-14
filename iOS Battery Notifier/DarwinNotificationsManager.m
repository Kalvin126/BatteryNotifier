//
//  DarwinNotificationsManager.m
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/22/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DarwinNotificationsManager.h"

@implementation DarwinNotificationsManager {
    NSMutableDictionary * handlers;
}

+ (instancetype)defaultCenter {
    static id instance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        handlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)observeNotificationForName:(NSString *)name callback:(void (^)(void))callback {
    handlers[name] = callback;
    CFNotificationCenterRef center = CFNotificationCenterGetLocalCenter();
    CFNotificationCenterAddObserver(center, (__bridge const void *)(self), defaultNotificationCallback, (__bridge CFStringRef)name, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

- (void)postNotificationWithName:(NSString *)name {
    CFNotificationCenterRef center = CFNotificationCenterGetLocalCenter();
    CFNotificationCenterPostNotification(center, (__bridge CFStringRef)name, NULL, NULL, YES);
}

- (void)notificationCallbackReceivedWithName:(NSString *)name {
    void (^callback)(void) = handlers[name];
    callback();
}

void defaultNotificationCallback (CFNotificationCenterRef center,
                                  void *observer,
                                  CFStringRef name,
                                  const void *object,
                                  CFDictionaryRef userInfo)
{
    NSString *identifier = (__bridge NSString *)name;
    [[DarwinNotificationsManager defaultCenter] notificationCallbackReceivedWithName:identifier];
}


- (void)dealloc {
    CFNotificationCenterRef center = CFNotificationCenterGetLocalCenter();
    CFNotificationCenterRemoveEveryObserver(center, (__bridge const void *)(self));
}


@end
