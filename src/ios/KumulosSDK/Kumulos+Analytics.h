//
//  Kumulos+Kumulos_Analytics.h
//  KumulosSDK iOS
//

#import <Foundation/Foundation.h>
#import "Kumulos.h"

@interface Kumulos (Analytics)

/**
 * Logs an analytics event to the local database
 * @param eventType Unique identifier for the type of event
 * @param properties Optional meta-data about the event
 */
- (void) trackEvent:(NSString* _Nonnull) eventType withProperties:(NSDictionary* _Nullable) properties;

/**
 * Logs an analytics event to the local database then flushes all locally stored events to the server
 * @param eventType Unique identifier for the type of event
 * @param properties Optional meta-data about the event
 */
- (void) trackEventImmediately:(NSString* _Nonnull) eventType withProperties:(NSDictionary* _Nullable) properties;

/**
 * Associates a user identifier with the current Kumulos installation record.
 * @param userIdentifier Unique identifier for the current user
 */
- (void) associateUserWithInstall:(NSString* _Nonnull) userIdentifier;

/**
 * Associates a user identifier with the current Kumulos installation record, additionally setting the attributes for the user
  * @param userIdentifier Unique identifier for the current user
  * @param attributes JSON encodable dictionary of attributes to store for the user
 */
- (void) associateUserWithInstall:(NSString* _Nonnull) userIdentifier attributes:(NSDictionary* _Nonnull) attributes;

@end
