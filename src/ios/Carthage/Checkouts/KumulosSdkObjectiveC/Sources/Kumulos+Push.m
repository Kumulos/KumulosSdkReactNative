//
//  Kumulos+Push.m
//  KumulosSDK
//
//  Copyright © 2016 kumulos. All rights reserved.
//

@import UserNotifications;
#import "Kumulos+Push.h"
#import "Kumulos+Protected.h"
#import "MobileProvision.h"
#import "KumulosEvents.h"

static NSInteger const KSPushTokenTypeProduction = 1;
static NSInteger const KSPushDeviceType = 1;

@implementation Kumulos (Push)

- (void) pushRequestDeviceToken {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter* notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        UNAuthorizationOptions options = (UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge);
        [notificationCenter requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError* error) {
            if (!granted || error != nil) {
                return;
            }
            
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }];
    } else {
        [self legacyRegisterForToken];
    }
}

- (void) legacyRegisterForToken {
    UIUserNotificationType types = (UIUserNotificationType) (UIUserNotificationTypeBadge |
                                                             UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
    
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void) pushRegisterWithDeviceToken:(NSData*)deviceToken {
    NSString* token = [self pushTokenFromData:deviceToken];
    
    NSDictionary* info = @{@"token": token,
                           @"type": @(KSPushDeviceType),
                           @"iosTokenType": [self pushGetTokenType]};
    
    [self.analyticsHelper trackEvent:KumulosEventPushRegistered withProperties:info flushingImmediately:YES];
}

- (void) pushTrackOpenFromNotification:(NSDictionary* _Nullable)userInfo {
    if (nil == userInfo) {
        return;
    }
    
    NSDictionary* notification = userInfo;
    NSDictionary* custom = notification[@"custom"];
    
    if (nil == custom || !custom[@"i"]) {
        return;
    }
    
    NSDictionary* params = @{@"id": custom[@"i"]};
    
    [self.analyticsHelper trackEvent:KumulosEventPushOpened withProperties:params];
}

- (NSNumber*) pushGetTokenType {
    UIApplicationReleaseMode releaseMode = [MobileProvision releaseMode];
    
    if (releaseMode == UIApplicationReleaseAdHoc
        || releaseMode == UIApplicationReleaseDev
        || releaseMode == UIApplicationReleaseWildcard) {
        return @(releaseMode + 1);
    }
    
    return @(KSPushTokenTypeProduction);
}

- (NSString*) pushTokenFromData:(NSData*) deviceToken {
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    
    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    return [token copy];
}

@end
