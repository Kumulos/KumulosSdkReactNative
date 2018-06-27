//
//  KSAPIOperation.h
//  KumulosSDK
//
//  Copyright © 2016 kumulos. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Kumulos;
@class KSAPIResponse;

@protocol KSAPIOperationDelegate <NSObject>

@required
/**
 * Called back when the API operation set with this delegate successfully completes
 * @param operation The API operation that completed
 * @param response The response from the Kumulos API method
 */
- (void) operation:(KSAPIOperation* _Nonnull)operation didCompleteWithResponse:(KSAPIResponse* _Nonnull)response;

@optional
/**
 * Called back when the API operation set with this delegate fails to complete successfully
 * @param operation The API operation that failed
 * @param error The error that caused the operation to fail
 */
- (void) operation:(KSAPIOperation* _Nonnull)operation didFailWithError:(NSError* _Nonnull)error;

@end

/**
 * Represents an API method request to the Kumulos RPC interface
 */
@interface KSAPIOperation : NSOperation

/// The alias of the API method called by this operation
@property (nonatomic,readonly,nonnull) NSString* method;
/// The parameters that were sent as part of this API method call
@property (nonatomic,readonly,nullable) NSDictionary* params;

/// The delegate that will be called back upon completion of this API operation.
@property (nonatomic,weak,nullable) id <KSAPIOperationDelegate> delegate;
/// The success handler block for this operation
@property (nonatomic,readonly,nullable,copy) KSAPIOperationSuccessBlock successBlock;
/// The failure handler block for this operation
@property (nonatomic,readonly,nullable,copy) KSAPIOperationFailureBlock failureBlock;

- (instancetype _Nonnull) initWithKumulos:(Kumulos* _Nonnull)kumulos method:(NSString* _Nonnull)method params:(NSDictionary* _Nullable)params success:(KSAPIOperationSuccessBlock)successBlock failure:(KSAPIOperationFailureBlock)failureBlock andDelegate:(id <KSAPIOperationDelegate> _Nullable)delegate;

@end
