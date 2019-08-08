
#import "KSKumulosReactNative.h"

@import CoreLocation;
#import <KumulosSDK/KumulosSDK.h>

@implementation KSKumulosReactNative

//- (dispatch_queue_t)methodQueue
//{
//    return dispatch_get_main_queue();
//}

RCT_EXPORT_MODULE(kumulos)

RCT_EXPORT_METHOD(initBaseSdk:(NSDictionary*) params)
{
    NSString* apiKey = params[@"apiKey"];
    NSString* secretKey = params[@"secretKey"];
    NSNumber* enableCrashReporting = params[@"enableCrashReporting"];
    NSDictionary* sdkInfo = params[@"sdkInfo"];
    NSDictionary* runtimeInfo = params[@"runtimeInfo"];

    KSConfig* config = [KSConfig configWithAPIKey:apiKey andSecretKey:secretKey];

    if ([enableCrashReporting isEqual: @(YES)]) {
        [config enableCrashReporting];
    }

    [config setSdkInfo:sdkInfo];
    [config setRuntimeInfo:runtimeInfo];

    [config setTargetType:TargetTypeRelease];
#ifdef DEBUG
    [config setTargetType:TargetTypeDebug];
#endif

    [Kumulos initializeWithConfig:config];
}

RCT_EXPORT_METHOD(getInstallId:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    resolve([Kumulos installId]);
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
  
