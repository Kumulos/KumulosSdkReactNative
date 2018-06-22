//
//  KSResponse.m
//  KumulosSDK
//
//  Copyright © 2016 kumulos. All rights reserved.
//

#import "KSAPIResponse.h"

static NSString* const KSApiKeyPayload = @"payload";
static NSString* const KSApiKeyProcessingTime = @"requestProcessingTime";
static NSString* const KSApiKeyReceivedTime = @"requestReceivedTime";
static NSString* const KSApiKeyTimestamp = @"timestamp";
static NSString* const KSApiKeyResponseCode = @"responseCode";
static NSString* const KSApiKeyResponseMessage = @"responseMessage";
static NSString* const KSApiKeyMaxProcessingTime = @"maxProcessingTime";


@implementation KSAPIResponse

+ (instancetype) createFromResponseData:(id)responseData {
    KSAPIResponse* res = [[KSAPIResponse alloc] init];
    res->_payload = [responseData objectForKey:KSApiKeyPayload];
    res->_requestProcessingTime = [responseData objectForKey:KSApiKeyProcessingTime];
    res->_requestReceivedTime = [responseData objectForKey:KSApiKeyReceivedTime];
    res->_timestamp = [responseData objectForKey:KSApiKeyTimestamp];
    res->_responseCode = [responseData objectForKey:KSApiKeyResponseCode];
    res->_responseMessage = [responseData objectForKey:KSApiKeyResponseMessage];
    res->_maxProcessingTime = [responseData objectForKey:KSApiKeyMaxProcessingTime];
    
    return res;
}

@end
