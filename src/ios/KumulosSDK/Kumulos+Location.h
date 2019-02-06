//
//  Kumulos+Location.h
//  KumulosSDK
//
//

#import <CoreLocation/CoreLocation.h>

#import "Kumulos.h"

@interface Kumulos (Location)

/**
 * Updates the location of this installation in Kumulos
 * Accurate locaiton information is used for geofencing
 * @param location The current device location
 */
- (void) sendLocationUpdate:(CLLocation* _Nullable) location;

/**
 * Records a beacon proximity event for an iBeacon.
 * Beacon proximity events can be used for automations in Kumulos.
 * @param beacon The beacon you wish to track proximity to
 */
- (void) sendiBeaconProximity:(CLBeacon* _Nullable) beacon;

@end
