//
//  KumulosSDK.h
//  KumulosSDK
//
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

//! Project version number for KumulosSDK.
FOUNDATION_EXPORT double KumulosSDKVersionNumber;

//! Project version string for KumulosSDK.
FOUNDATION_EXPORT const unsigned char KumulosSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Sources/PublicHeader.h>

#import "Kumulos.h"

#if TARGET_OS_IOS
#import "Kumulos+Push.h"
#import "KumulosPushSubscriptionManager.h"
#import "Kumulos+Location.h"
#import "Kumulos+Analytics.h"
#endif

#import "KSAPIOperation.h"
#import "KSAPIResponse.h"
#import "Kumulos+Crash.h"

