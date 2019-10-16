//
//  DarwinNotificationsManager.h
//  iOS Battery Notifier
//
//  Created by Kalvin Loc on 3/22/16.
//  Copyright © 2016 Red Panda. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DarwinNotificationsManager : NSObject

@property(class, readonly, strong) DarwinNotificationsManager *defaultCenter NS_SWIFT_NAME(default);

@property (strong, nonatomic) id someProperty;

- (void)observeNotificationForName:(NSString *)name callback:(void (^)(void))callback;
- (void)postNotificationWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END

/*
 http://stackoverflow.com/questions/26637023/how-to-properly-use-cfnotificationcenteraddobserver-in-swift-for-ios
*/
