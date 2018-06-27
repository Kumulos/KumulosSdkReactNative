//
//  Kumulos.h
//  KumulosSDK
//
//  Copyright © 2016 kumulos. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
#else
#import <UIKit/UIKit.h>
#endif

@class KSAPIOperation;
@class KSAPIResponse;
@protocol KSAPIOperationDelegate;

typedef void (^ _Nullable KSAPIOperationSuccessBlock)(KSAPIResponse* _Nonnull, KSAPIOperation* _Nonnull);
typedef void (^ _Nullable KSAPIOperationFailureBlock)(NSError* _Nonnull, KSAPIOperation* _Nonnull);

/**
 * Config options for initializing a Kumulos instance
 */
@interface KSConfig : NSObject

@property (nonatomic,readonly) NSString* _Nonnull apiKey;
@property (nonatomic,readonly) NSString* _Nonnull secretKey;
@property (nonatomic,readonly) BOOL crashReportingEnabled;
@property (nonatomic,readonly) NSUInteger sessionIdleTimeoutSeconds;

@property (nonatomic,readonly) NSDictionary* _Nullable runtimeInfo;
@property (nonatomic,readonly) NSDictionary* _Nullable sdkInfo;

+ (instancetype _Nullable) configWithAPIKey:(NSString* _Nonnull)APIKey andSecretKey:(NSString* _Nonnull)secretKey;

- (instancetype _Nullable) init NS_UNAVAILABLE;

- (instancetype _Nonnull) enableCrashReporting;

- (instancetype _Nonnull) setSessionIdleTimeout:(NSUInteger)timeoutSeconds;

- (instancetype _Nonnull) setRuntimeInfo:(NSDictionary* _Nonnull)info;
- (instancetype _Nonnull) setSdkInfo:(NSDictionary* _Nonnull)info;

@end

/**
 * The main Kumulos SDK class allows interaction API methods
 * and the push notification service.
 */
@interface Kumulos : NSObject

/// Shared Kumulos instance when using the singleton style initializer
@property (class,nonatomic,nullable,readonly) Kumulos* shared;

/// The Kumulos RPC API session token
@property (nonnull) NSString* sessionToken;

/// The Kumulos instance configuration
@property (nonnull) KSConfig* config;

/**
 * Gets the unique Kumulos installation ID
 * @returns NSString
 */
+ (NSString* _Nonnull) installId;

/**
 * Initializes the shared Kumulos instance with the given config
 * @param config The Kumulos client configuration
 * @returns Kumulos
 */
+ (instancetype _Nullable) initializeWithConfig:(KSConfig* _Nonnull)config;

/**
 * Initializes Kumulos with the given config
 * @param config The Kumulos client configuration
 * @returns Kumulos
 */
- (instancetype _Nullable) initWithConfig:(KSConfig* _Nonnull)config;

/**
 * Initializes Kumulos with the given API key & secret
 * @param APIKey The Kumulos app API key
 * @param secretKey The Kumulos app secret key
 * @returns Kumulos
 */
- (instancetype _Nullable) initWithAPIKey:(NSString* _Nonnull)APIKey andSecretKey:(NSString* _Nonnull)secretKey;

/**
 * Calls a Kumulos API method, passing results in block handlers
 * @param method The Kumulos API method alias
 * @param success The success result handler block
 * @param failure The error result handler block
 * @returns KSAPIOperation
 */
- (KSAPIOperation* _Nonnull) callMethod:(NSString* _Nonnull)method withSuccess:(KSAPIOperationSuccessBlock)success andFailure:(KSAPIOperationFailureBlock)failure;

/**
 * Calls a Kumulos API method, passing results in block handlers
 * @param method The Kumulos API method alias
 * @param params The API method parameters map
 * @param success The success result handler block
 * @param failure The error result handler block
 * @returns KSAPIOperation
 */
- (KSAPIOperation* _Nonnull) callMethod:(NSString* _Nonnull)method withParams:(NSDictionary* _Nullable)params success:(KSAPIOperationSuccessBlock)success andFailure:(KSAPIOperationFailureBlock)failure;

/**
 * Calls a Kumulos API method, passing results to the specified delegate
 * @param method The Kumulos API method alias
 * @param delegate The KSAPIOperationDelegate handler for success and failure
 * @returns KSAPIOperation
 */
- (KSAPIOperation* _Nonnull) callMethod:(NSString* _Nonnull)method withDelegate:(id <KSAPIOperationDelegate> _Nullable) delegate;

/**
 * Calls a Kumulos API method, passing results to the specified delegate
 * @param method The Kumulos API method alias
 * @param params The API method parameters map
 * @param delegate The KSAPIOperationDelegate handler for success and failure
 * @returns KSAPIOperation
 */
- (KSAPIOperation* _Nonnull) callMethod:(NSString* _Nonnull)method withParams:(NSDictionary* _Nullable)params andDelegate:(id <KSAPIOperationDelegate> _Nullable)delegate;

@end

/// The error domain used by the Kumulos SDK
static NSString* _Nonnull const KSErrorDomain = @"com.kumulos.errors";

/// Error codes the SDK can produce within the KSErrorDomain
typedef NS_ENUM(NSInteger, KSErrorCode) {
    KSErrorCodeNetworkError,
    KSErrorCodeRpcError,
    KSErrorCodeUnknownError,
    KSErrorCodeValidationError,
    KSErrorCodeHttpBadStatus
};
