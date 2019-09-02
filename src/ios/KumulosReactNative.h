
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <React/RCTEventEmitter.h>
#import <KumulosSDK/KumulosSDK.h>

@interface KumulosReactNative : RCTEventEmitter <RCTBridgeModule>

+ (void)initializeWithConfig:(KSConfig*)config;

@end
