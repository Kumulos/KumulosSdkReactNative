//
//  AnalyticsHelper.h
//  KumulosSDK iOS
//

#import <Foundation/Foundation.h>
#import "Kumulos.h"

@interface AnalyticsHelper : NSObject

- (instancetype _Nullable) initWithKumulos:(Kumulos* _Nonnull) kumulos;
- (void) trackEvent:(NSString* _Nonnull) eventType withProperties:(NSDictionary* _Nullable) properties;
- (void) trackEvent:(NSString* _Nonnull) eventType withProperties:(NSDictionary* _Nullable) properties flushingImmediately:(BOOL)flushImmediately;

@end
