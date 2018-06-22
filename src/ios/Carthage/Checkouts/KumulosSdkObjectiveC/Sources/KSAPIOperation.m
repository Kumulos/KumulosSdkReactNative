//
//  KSAPIOperation.m
//  KumulosSDK
//
//  Copyright © 2016 kumulos. All rights reserved.
//

#import "Kumulos.h"
#import "Kumulos+Protected.h"
#import "KSAPIOperation.h"
#import "KSAPIResponse.h"

@interface KSAPIResponse (Factory)

+ (instancetype) createFromResponseData:(id)responseData;

@end

@interface KSAPIOperation ()

@property (nonatomic) Kumulos* kumulos;

@end

@implementation KSAPIOperation

- (instancetype _Nonnull) initWithKumulos:(Kumulos* _Nonnull)kumulos method:(NSString* _Nonnull)method params:(NSDictionary* _Nullable)params success:(KSAPIOperationSuccessBlock)successBlock failure:(KSAPIOperationFailureBlock)failureBlock andDelegate:(id<KSAPIOperationDelegate> _Nullable)delegate {
    
    if (self = [super init]) {
        self.kumulos = kumulos;
        self->_method = method;
        self->_params = params;
        self->_successBlock = successBlock;
        self->_failureBlock = failureBlock;
        self.delegate = delegate;
    }
    
    return self;
}

- (void) main {
    if (self.isCancelled) {
        return;
    }
    
    NSString* path = [self buildMethodPath];
    NSDictionary* params = [self prepareParams];
    
    [self.kumulos.rpcHttpClient POST:path parameters:params progress:nil
                             success:^(NSURLSessionTask* task, id response) {
                                 if (self.isCancelled) {
                                     return;
                                 }
                                 
                                 [self handleResponse:response];
                             }
                             failure:^(NSURLSessionTask* task, NSError* error) {
                                 if (self.isCancelled) {
                                     return;
                                 }
                                 
                                 [self handleNetworkingError:error];
                             }];
}

- (void) handleResponse:(id)response {
    KSAPIResponse* apiResponse = [KSAPIResponse createFromResponseData:response];
    
    NSString* sessionToken = [response objectForKey:@"sessionToken"];
    if (sessionToken) {
        self.kumulos.sessionToken = sessionToken;
    }
    
    if ([apiResponse.responseCode intValue] != 1) {
        [self handleRpcErrorWithResponse:apiResponse];
        return;
    }
    
    [self invokeSuccess:apiResponse];
}

- (void) invokeDelegateSelector:(SEL)selector withArg:(id)arg {
    id <KSAPIOperationDelegate> delegate = self.delegate;
    
    if (!delegate || ![delegate respondsToSelector:selector]) {
        return;
    }
    
    NSMethodSignature* signature = [[delegate class] instanceMethodSignatureForSelector:selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    
    [invocation setTarget:delegate];
    [invocation setSelector:selector];
    
    KSAPIOperation* operation = self;
    [invocation setArgument:&operation atIndex:2];
    [invocation setArgument:&arg atIndex:3];
    
    [invocation invoke];
}

- (void) invokeSuccess:(KSAPIResponse*)response {
    if (self.successBlock != nil) {
        self.successBlock(response, self);
        return;
    }
    
    
    SEL selector = @selector(operation:didCompleteWithResponse:);
    [self invokeDelegateSelector:selector withArg:response];
}

- (void) invokeFailure:(NSError*)error {
    if (self.failureBlock != nil) {
        self.failureBlock(error, self);
        return;
    }

    SEL selector = @selector(operation:didFailWithError:);
    [self invokeDelegateSelector:selector withArg:error];
}

- (void) handleRpcErrorWithResponse:(KSAPIResponse*) apiResponse {
    NSError* error = [NSError errorWithDomain:KSErrorDomain code:KSErrorCodeRpcError userInfo:@{NSLocalizedDescriptionKey: [apiResponse.responseMessage copy], @"response": apiResponse}];
    
    [self invokeFailure:error];
}

- (void) handleNetworkingError:(NSError*)error {
    [self invokeFailure:[NSError errorWithDomain:KSErrorDomain code:KSErrorCodeNetworkError userInfo:@{NSLocalizedDescriptionKey: @"Networking error", NSUnderlyingErrorKey: error}]];
}

- (NSString*) buildMethodPath {
    return [NSString stringWithFormat:@"/b2.2/%@/%@.plist", self.kumulos.apiKey, self.method];
}

- (NSDictionary*) prepareParams {
    NSUInteger paramCount = (self.params) ? self.params.count : 0;
    NSMutableDictionary* encodedParams = [NSMutableDictionary dictionaryWithCapacity:paramCount];
    
    if (self.params) {
        for (id key in self.params) {
            id current = [self.params objectForKey:key];
            
            if ([current isKindOfClass:[NSData class]] || [current isKindOfClass:[NSMutableData class]]) {
                encodedParams[key] = [current base64EncodedStringWithOptions:0];
            }
            else if ([current isKindOfClass:[NSDate class]]) {
                encodedParams[key] = [NSNumber numberWithDouble:[current timeIntervalSince1970]];
            }
            else {
                encodedParams[key] = current;
            }
        }
    }
    
    NSString* installId = [Kumulos installId];
    
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    NSString* deviceType = @"1";
#else
    NSString* deviceType = @"2";
#endif
    
    NSDictionary* params = @{@"params": encodedParams,
                             @"deviceType": deviceType,
                             @"deviceID": installId,
                             @"installId": installId,
                             @"sessionToken": self.kumulos.sessionToken};
    
    return params;
}

@end
