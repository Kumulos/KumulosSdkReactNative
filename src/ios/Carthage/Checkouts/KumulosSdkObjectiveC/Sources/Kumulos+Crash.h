//
//  Kumulos+Crash.h
//  KumulosSDK
//
//

#import <Foundation/Foundation.h>
#import "Kumulos.h"

@interface Kumulos (Crash)

/**
 * Logs an unexpected state to Kumulos Crash Reporting
 * @param name Exception group
 * @param reason Some more details
 * @param language Scripting language or native?
 * @param lineNumber The line that cuased the error
 * @param stackTrace Backtrace frames (strings or dictionaries)
 * @param loggingAllThreads Should all thread state be captured?
 */
- (void) logExceptionWithName: (NSString* _Nonnull) name reason:(NSString* _Nonnull) reason language:(NSString* _Nonnull) language lineNumber: (NSString* _Nullable) lineNumber stackTrace:(NSArray<id>* _Nullable) stackTrace loggingAllThreads:(BOOL) loggingAllThreads;

@end
