//
//  Kumulos+Push.h
//  KumulosSDK
//
//  Copyright © 2016 kumulos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Kumulos.h"

@interface Kumulos (Push)

/**
 * Requests a push token from the user.
 * 
 * Will prompt for alert, sound, and badge permissions.
 *
 * After the permission is granted, you should call Kumulos#pushRegisterWithDeviceToken to complete the registration flow.
 */
- (void) pushRequestDeviceToken;

/**
 * Registers the given device token with Kumulos for the current unique installation
 * @param deviceToken The device's push token
 */
- (void) pushRegisterWithDeviceToken:(NSData* _Nonnull)deviceToken;

/**
 * Tracks a conversion from a notification object to let Kumulos know that the given push 'converted' the user
 * @param userInfo The remote notification object userInfo that was receieved by the device
 */
- (void) pushTrackOpenFromNotification:(NSDictionary* _Nullable)userInfo;

@end
