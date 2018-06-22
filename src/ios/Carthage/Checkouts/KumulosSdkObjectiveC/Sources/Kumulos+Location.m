//
//  Kumulos+Location.m
//  KumulosSDK
//
//

#import "KumulosEvents.h"
#import "Kumulos+Location.h"
#import "Kumulos+Protected.h"

@implementation Kumulos (Location)

- (void) sendLocationUpdate:(CLLocation*) location {
    if (nil == location) {
        return;
    }

    NSDictionary *jsonDict = @{@"lat" : @(location.coordinate.latitude),
                               @"lng" : @(location.coordinate.longitude)
                               };
    
    [self.analyticsHelper trackEvent:KumulosEventLocationUpdated withProperties:jsonDict flushingImmediately:YES];
}

- (void) sendiBeaconProximity:(CLBeacon *)beacon {
    if (nil == beacon) {
        return;
    }

    NSDictionary *props = @{
                            @"type": @1,
                            @"uuid": [beacon.proximityUUID UUIDString],
                            @"major": beacon.major,
                            @"minor": beacon.minor,
                            @"proximity": @(beacon.proximity)
                            };
    
    [self.analyticsHelper trackEvent:KumulosEventBeaconEnteredProximity withProperties:props flushingImmediately:YES];
}

@end
