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

typedef NS_ENUM(NSUInteger, SFLoggerLogLevel) {
    SFLoggerLogLevelError = DDLogLevelError,
    SFLoggerLogLevelDebug = DDLogLevelDebug,
    SFLoggerLogLevelVerbose = DDLogLevelVerbose
};

static DDLogLevel ddLogLevel = (DDLogLevel)SFLoggerLogLevelError;

@interface SFLogger : NSObject

#pragma mark - Properties

// Config properties
@property (assign, nonatomic) SFLoggerLogLevel loggerLevel;
@property (strong, nonatomic) DDAbstractLogger <DDLogger> *logger;

#pragma mark - Convenience Initialisers

+(instancetype)loggerWithDDLoggerInstance:(NSObject<DDLogger> *)logger loggerLevel:(SFLoggerLogLevel)loggerLevel;

- (instancetype)initWithDDLoggerInstance:(NSObject <DDLogger>*)logger loggerLevel:(SFLoggerLogLevel)loggerLevel NS_DESIGNATED_INITIALIZER;

#pragma mark - Public Methods

-(void)logError:(id)format, ...;
-(void)logDebug:(id)format, ...;
-(void)logVerbose:(id)format, ...;

@end
