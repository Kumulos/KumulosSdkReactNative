
#import "KumulosReactNative.h"
@import CoreLocation;
@import UserNotifications;
#import <React/RCTVersion.h>

static KSInAppDeepLinkHandlerBlock ksInAppDeepLinkHandler;
static KSPushOpenedHandlerBlock ksPushOpenedHandler;
API_AVAILABLE(ios(10.0))
static KSPushReceivedInForegroundHandlerBlock ksPushReceivedHandler;
static KSPushNotification* _Nullable ksColdStartPush;

static const NSString* KSReactNativeVersion = @"5.1.0";
static const NSUInteger KSSdkTypeReactNative = 9;
static const NSUInteger KSRuntimeTypeReactNative = 7;

@implementation KumulosReactNative

//- (dispatch_queue_t)methodQueue
//{
//    return dispatch_get_main_queue();
//}

+ (void)initializeWithConfig:(KSConfig*)config {
    [config setInAppDeepLinkHandler:^(NSDictionary * _Nonnull data) {
        if (ksInAppDeepLinkHandler) {
            ksInAppDeepLinkHandler(data);
        }
    }];
    [config setPushOpenedHandler:^(KSPushNotification * _Nonnull notification) {
        if (ksPushOpenedHandler) {
            ksPushOpenedHandler(notification);
        } else if (!ksColdStartPush) {
            ksColdStartPush = notification;
        }
    }];
    if (@available(iOS 10.0, *)) {
        [config setPushReceivedInForegroundHandler:^(KSPushNotification* _Nonnull push, KSPushReceivedInForegroundCompletionHandler completionHandler) {
            if (ksPushReceivedHandler) {
                ksPushReceivedHandler(push, completionHandler);
            }

            completionHandler(UNNotificationPresentationOptionAlert);
        }];
    }

    [config setSdkInfo:@{@"id": @(KSSdkTypeReactNative), @"version": KSReactNativeVersion}];

    NSDictionary* rnVersion = RCTGetReactNativeVersion();
    [config setRuntimeInfo:@{@"id": @(KSRuntimeTypeReactNative), @"version": [NSString
                                                                              stringWithFormat:@"%@.%@.%@",
                                                                              rnVersion[RCTVersionMajor],
                                                                              rnVersion[RCTVersionMinor],
                                                                              rnVersion[RCTVersionPatch]]}];

    [config setTargetType:TargetTypeRelease];
#ifdef DEBUG
    [config setTargetType:TargetTypeDebug];
#endif

    [Kumulos initializeWithConfig:config];
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"kumulos.push.opened", @"kumulos.push.received", @"kumulos.inApp.deepLinkPressed"];
}

- (NSDictionary*) pushToDict:(KSPushNotification*)notification {
    NSDictionary* alert = notification.aps[@"alert"];

    return @{@"id": notification.id,
             @"title": alert ? alert[@"title"] : NSNull.null,
             @"message": alert ? alert[@"body"] : NSNull.null,
             @"data": notification.data,
             @"url": notification.url ? [notification.url absoluteString] : NSNull.null
             };
}

- (void)startObserving {
    ksInAppDeepLinkHandler = ^(NSDictionary * _Nonnull data) {
        [self sendEventWithName:@"kumulos.inApp.deepLinkPressed" body:data];
    };
    ksPushOpenedHandler = ^(KSPushNotification * _Nonnull notification) {
        [self sendEventWithName:@"kumulos.push.opened" body:[self pushToDict:notification]];
    };

    if (@available(iOS 10.0, *)) {
        ksPushReceivedHandler = ^(KSPushNotification* _Nonnull notification, KSPushReceivedInForegroundCompletionHandler completionHandler) {
            [self sendEventWithName:@"kumulos.push.received" body:[self pushToDict:notification]];
        };
    }

    if (ksColdStartPush) {
        ksPushOpenedHandler(ksColdStartPush);
        ksColdStartPush = nil;
    }
}

- (void)stopObserving {
    ksInAppDeepLinkHandler = nil;
    ksPushOpenedHandler = nil;
}

RCT_EXPORT_MODULE(kumulos)

RCT_EXPORT_METHOD(getInstallId:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    resolve(Kumulos.installId);
}

RCT_EXPORT_METHOD(getCurrentUserIdentifier:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    resolve(Kumulos.currentUserIdentifier);
}

RCT_EXPORT_METHOD(clearUserAssociation)
{
    [Kumulos.shared clearUserAssociation];
}

RCT_EXPORT_METHOD(trackEvent:(NSString*) eventType properties:(NSDictionary*) properties immediateFlush:(BOOL) immediateFlush)
{
    if (immediateFlush) {
        [Kumulos.shared trackEventImmediately:eventType withProperties:properties];
    }
    else {
        [Kumulos.shared trackEvent:eventType withProperties:properties];
    }
}

RCT_EXPORT_METHOD(sendLocationUpdate:(double)lat lng:(double)lng)
{
    CLLocation* location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];

    [Kumulos.shared sendLocationUpdate:location];
}

RCT_EXPORT_METHOD(associateUserWithInstall:(NSString*) userIdentifier attributes:(NSDictionary*)attributes)
{
    if (nil == attributes) {
        [Kumulos.shared associateUserWithInstall:userIdentifier];
    }
    else {
        [Kumulos.shared associateUserWithInstall:userIdentifier attributes:attributes];
    }
}

RCT_EXPORT_METHOD(pushRequestDeviceToken)
{
    [Kumulos.shared pushRequestDeviceToken];
}

RCT_EXPORT_METHOD(pushUnregister)
{
    [Kumulos.shared pushUnregister];
}

RCT_EXPORT_METHOD(inAppUpdateConsentForUser:(BOOL)consented)
{
    [KumulosInApp updateConsentForUser:consented];
}

RCT_EXPORT_METHOD(inAppGetInboxItems:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    NSArray<KSInAppInboxItem*>* inboxItems = [KumulosInApp getInboxItems];
    NSMutableArray<NSDictionary*>* items = [[NSMutableArray alloc] initWithCapacity:inboxItems.count];

    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setTimeStyle:NSDateFormatterFullStyle];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    for (KSInAppInboxItem* item in inboxItems) {
        [items addObject:@{@"id": item.id,
                           @"title": item.title,
                           @"subtitle": item.subtitle,
                           @"availableFrom": item.availableFrom ? [formatter stringFromDate:item.availableFrom] : NSNull.null,
                           @"availableTo": item.availableTo ? [formatter stringFromDate:item.availableTo] : NSNull.null,
                           @"dismissedAt": item.dismissedAt ? [formatter stringFromDate:item.dismissedAt] : NSNull.null}];
    }
    resolve(items);
}

RCT_EXPORT_METHOD(inAppPresentItemWithId:(NSNumber* _Nonnull)ident resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    NSArray<KSInAppInboxItem*>* inboxItems = [KumulosInApp getInboxItems];
    for (KSInAppInboxItem* msg in inboxItems) {
        if ([msg.id isEqualToNumber:ident]) {
            KSInAppMessagePresentationResult result = [KumulosInApp presentInboxMessage:msg];

            if (result == KSInAppMessagePresentationPresented) {
                resolve(nil);
            } else {
                reject(@"0", @"Failed to present message", nil);
            }

            return;
        }
    }

    reject(@"0", @"Message not found", nil);
}

RCT_EXPORT_METHOD(pushStoreToken:(NSString*) token)
{
    // Data conversion from https://stackoverflow.com/a/7318062/543200
    NSMutableData* tokenData = [[NSMutableData alloc] init];

    unsigned char byte;
    char byteChars[3] = {'\0','\0','\0'};
    int i;

    for (i = 0; i < token.length / 2; i++) {
        byteChars[0] = [token characterAtIndex:i * 2];
        byteChars[1] = [token characterAtIndex:(i * 2) + 1];
        byte = strtol(byteChars, NULL, 16);
        [tokenData appendBytes:&byte length:1];
    }

    [Kumulos.shared pushRegisterWithDeviceToken:tokenData];
}

@end
