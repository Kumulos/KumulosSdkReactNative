//
//  Kumulos+Crash.m
//  KumulosSDK
//
//  Created by cgwyllie on 09/10/2017.
//
//

#import "Kumulos+Crash.h"

#ifdef COCOAPODS
#import "KSCrash.h"
#else
#import <KSCrash/KSCrash.h>
#endif

@implementation Kumulos (Crash)

- (void) logExceptionWithName:(NSString *)name reason:(NSString *)reason language:(NSString *)language lineNumber:(NSString *)lineNumber stackTrace:(NSArray<id> *)stackTrace loggingAllThreads:(BOOL)loggingAllThreads {
    [[KSCrash sharedInstance] reportUserException:name reason:reason language:language lineOfCode:lineNumber stackTrace:stackTrace logAllThreads:loggingAllThreads terminateProgram:NO];
    
    [[KSCrash sharedInstance] sendAllReportsWithCompletion:^(NSArray *filteredReports, BOOL completed, NSError *error) {
        // Noop
    }];
}

@end
