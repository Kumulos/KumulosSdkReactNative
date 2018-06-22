//
//  Kumulos+Kumulos_Analytics.m
//  KumulosSDK iOS
//

#import "KumulosEvents.h"
#import "Kumulos+Analytics.h"
#import "Kumulos+Protected.h"

@implementation Kumulos (Analytics)

- (void) trackEvent:(NSString *)eventType withProperties:(NSDictionary *)properties {
    [self.analyticsHelper trackEvent:eventType withProperties:properties];
}

- (void) trackEventImmediately:(NSString *)eventType withProperties:(NSDictionary *)properties {
    [self.analyticsHelper trackEvent:eventType withProperties:properties flushingImmediately:YES];
}

- (void) associateUserWithInstall:(NSString *)userIdentifier {
    if (!userIdentifier || [userIdentifier isEqualToString:@""]) {
        NSLog(@"User identifier cannot be empty, aborting!");
        return;
    }
    
    NSDictionary* params = @{ @"id": userIdentifier };
    [self.analyticsHelper trackEvent:KumulosEventUserAssociated withProperties:params];
}

- (void) associateUserWithInstall:(NSString *)userIdentifier attributes:(NSDictionary * _Nonnull)attributes {
    if (!userIdentifier || [userIdentifier isEqualToString:@""]) {
        NSLog(@"User identifier cannot be empty, aborting!");
        return;
    }
    
    NSDictionary* params = @{ @"id": userIdentifier, @"attributes": attributes };
    [self.analyticsHelper trackEvent:KumulosEventUserAssociated withProperties:params];
}

@end
