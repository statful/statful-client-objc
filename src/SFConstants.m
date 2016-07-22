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

#include "SFConstants.h"

@implementation SFConstants
//Primitive Types
NSString* const kApiPath = @"/tel/v2.0/metrics";
NSString* const kDefaultNamespace = @"application";
NSString* const kUserAgent = @"statful-client-objc";
SFLoggerLogLevel kDefaultLoggerLevel = SFLoggerLogLevelError;
NSString* const kDefaultPort = @"2013";
NSString* const kDefaultHost = @"127.0.0.1";

//OBJ-C Objects
NSDictionary* kDefaultTags;
NSArray* kDefaultAggs;
NSNumber*  kDefaultAggFreq;
NSDictionary* kDefaultDefaults;
NSArray* kImplementedMethods;
NSNumber* kDefaultFlushSize;
NSNumber* kDefaultFlushInterval;
NSNumber* kDefaultSampleRate;
NSNumber* kDefaultDryrun;
NSNumber* kDefaultTimeout;
NSNumber* kDefaultSecure;
DDAbstractLogger <DDLogger>* kDefaultLogger;

//Function to init object constants
void __attribute__((constructor)) initializeConstants() {
    kDefaultTags = @{};
    kDefaultAggs = @[];
    kDefaultAggFreq = @10;
    kImplementedMethods = @[@"counter", @"gauge", @"timer"];
    kDefaultDefaults = @{};
    kDefaultFlushSize = @10;
    kDefaultFlushInterval = @10;
    kDefaultSampleRate = @100;
    kDefaultDryrun = @NO;
    kDefaultTimeout = @2000;
    kDefaultSecure = @YES;
    kDefaultLogger = [DDTTYLogger sharedInstance];
}

@end
