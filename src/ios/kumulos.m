#import "kumulos.h"
#import "MobileProvision.h"

static NSInteger const KSPushTokenTypeProduction = 1;

@implementation kumulos

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(KSgetIosTokenType:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  UIApplicationReleaseMode releaseMode = [MobileProvision releaseMode];
  
  if (releaseMode == UIApplicationReleaseAdHoc
      || releaseMode == UIApplicationReleaseDev
      || releaseMode == UIApplicationReleaseWildcard) {
    resolve(@(releaseMode + 1));
    return;
  }
  
  resolve(@(KSPushTokenTypeProduction));
}

@end
