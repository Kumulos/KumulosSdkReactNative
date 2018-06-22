//
//  KumulosPushSubscriptionManager.h
//  KumulosSDK
//
//  Copyright © 2017 kumulos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Kumulos.h"

/**
 * Model representing a push channel & its subscription status
 */
@interface KSPushChannel : NSObject

@property (nonatomic,readonly,nonnull) NSString* uuid;
@property (nonatomic,readonly,nullable) NSString* name;
@property (nonatomic,readonly) BOOL isSubscribed;
@property (nonatomic,readonly,nullable) NSDictionary* meta;

@end

typedef void (^ _Nullable KSPushSubscriptionCompletionBlock)(NSError* _Nullable error);
typedef void (^ _Nonnull KSPushChannelsSuccessBlock)(NSError* _Nullable error, NSArray<KSPushChannel*>* _Nullable channels);
typedef void (^ _Nonnull KSPushChannelSuccessBlock)(NSError* _Nullable error, KSPushChannel* _Nullable channel);

/**
 * Class for managing the current installation's push channel subscriptions
 */
@interface KumulosPushSubscriptionManager : NSObject

- (instancetype _Nonnull) init NS_UNAVAILABLE;

/**
 * Initialize the subscription manager with a Kumulos client instance
 */
- (instancetype _Nonnull) initWithKumulos:(Kumulos* _Nonnull) client;


/**
 * Subscribes the current installation to the channels specified by the given unique identifiers
 *
 * Channels must exist before subscription will succeed.
 *
 * Existing & duplicate subscriptions are ignored.
 *
 * @param uuids The channel IDs to subscribe to
 */
- (void) subscribeToChannels:(NSArray<NSString*>* _Nonnull) uuids;

/**
 * Subscribes the current installation to the channels specified by the given unique identifiers
 *
 * Channels must exist before subscription will succeed.
 *
 * Existing & duplicate subscriptions are ignored.
 *
 * @param uuids The channel IDs to subscribe to
 * @param complete Handler for success/failure of the request
 */
- (void) subscribeToChannels:(NSArray<NSString*>* _Nonnull) uuids onComplete:(KSPushSubscriptionCompletionBlock) complete;

/**
 * Unsubscribes the current installation from the channels specified by the given unique identifiers
 *
 * @param uuids The channel IDs to unsubscribe from
 */
- (void) unsubscribeFromChannels:(NSArray<NSString*>* _Nonnull) uuids;

/**
 * Unsubscribes the current installation from the channels specified by the given unique identifiers
 *
 * @param uuids The channel IDs to unsubscribe from
 * @param complete Handler for success/failure of the request
 */
- (void) unsubscribeFromChannels:(NSArray<NSString*>* _Nonnull) uuids onComplete:(KSPushSubscriptionCompletionBlock) complete;

/**
 * Sets the current installation's push channel subscriptions to those specified by unique identifiers
 *
 * Existing channel subscriptions that are not included will be cleared.
 *
 * Channels must exist before subscription.
 *
 * @param uuids Unique channel identifiers to subscribe to
 */
- (void) setSubscriptions:(NSArray<NSString*>* _Nonnull) uuids;

/**
 * Sets the current installation's push channel subscriptions to those specified by unique identifiers
 *
 * Existing channel subscriptions that are not included will be cleared.
 *
 * Channels must exist before subscription.
 *
 * @param uuids Unique channel identifiers to subscribe to
 * @param complete Handler for success/failure of the request
 */
- (void) setSubscriptions:(NSArray<NSString*>* _Nonnull) uuids onComplete:(KSPushSubscriptionCompletionBlock) complete;

/**
 * Clears all of the current installation's push subscriptions
 */
- (void) clearSubscriptions;

/**
 * Clears all of the current installation's push subscriptions
 *
 * @param complete Handler for the success/failure of the request
 */
- (void) clearSubscriptions:(KSPushSubscriptionCompletionBlock) complete;

/**
 * Lists all of the channels available to this installation and their subscription status
 *
 * @param complete Handler for the list of push channels or any errors with the request
 */
- (void) listChannels:(KSPushChannelsSuccessBlock) complete;

/**
 * Creates a new push channel and optionally subscribes the current installation to it
 *
 * @param uuid Unique channel identifier
 * @param subscribe Allows subscribing the current installation as part of channel creation
 * @param name Optional name for the channel (required if shownInPortal is true)
 * @param shownInPortal Should the channel show up in the portal and be targetable from the Push Dashboard in the UI?
 * @param meta Optional meta-data about this channel
 */
- (void) createChannelWithUuid:(NSString* _Nonnull) uuid shouldSubscribe:(BOOL) subscribe name:(NSString* _Nullable) name showInPortal:(BOOL) shownInPortal andMeta:(NSDictionary* _Nullable) meta onComplete:(KSPushChannelSuccessBlock) complete;

@end
