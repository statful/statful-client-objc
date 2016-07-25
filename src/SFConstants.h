//
//  Copyright (c) 2016 Statful
//  http://www.statful.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#define CURRENT_TIMESTAMP [NSString stringWithFormat:@"%lu", [@([[NSDate date] timeIntervalSince1970]) integerValue] ]

NS_ASSUME_NONNULL_BEGIN

@interface SFConstants : NSObject
//Primitive Types
typedef NS_ENUM(short, SFClientTransport) {
    SFClientTransportTCP = 0,
    SFClientTransportUDP,
    SFClientTransportAPI,
};

typedef NS_ENUM(NSUInteger, SFLoggerLogLevel) {
    SFLoggerLogLevelError = DDLogLevelError,
    SFLoggerLogLevelDebug = DDLogLevelDebug,
    SFLoggerLogLevelVerbose = DDLogLevelVerbose
};
FOUNDATION_EXTERN NSString* const kApiPath;
FOUNDATION_EXTERN NSString* const kDefaultNamespace;
FOUNDATION_EXTERN NSString* const kUserAgent;
FOUNDATION_EXTERN SFLoggerLogLevel kDefaultLoggerLevel;
FOUNDATION_EXTERN NSString* const kDefaultPort;
FOUNDATION_EXTERN NSString* const kDefaultHost;

//OBJ-C Objects
FOUNDATION_EXTERN NSDictionary* kDefaultGlobalTags;
FOUNDATION_EXTERN NSNumber* kDefaultAggFreq;
FOUNDATION_EXTERN NSDictionary* kDefaultDefaults;
FOUNDATION_EXTERN NSArray* kImplementedMethods;
FOUNDATION_EXTERN NSNumber* kDefaultFlushSize;
FOUNDATION_EXTERN NSNumber* kDefaultFlushInterval;
FOUNDATION_EXTERN NSNumber* kDefaultSampleRate;
FOUNDATION_EXTERN DDAbstractLogger <DDLogger>* kDefaultLogger;
FOUNDATION_EXTERN NSNumber* kDefaultDryrun;
FOUNDATION_EXTERN NSNumber* kDefaultTimeout;
FOUNDATION_EXTERN NSNumber* kDefaultSecure;
FOUNDATION_EXTERN NSDictionary* kDefaultTagsByMethod;
FOUNDATION_EXTERN NSDictionary* kDefaultAggByMethod;
FOUNDATION_EXTERN NSArray* kSupportedAgg;
FOUNDATION_EXTERN NSArray* kSupportedAggFreq;
@end

NS_ASSUME_NONNULL_END
