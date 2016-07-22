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

#import "SFLogger.h"

static DDLogLevel ddLogLevel = (DDLogLevel)SFLoggerLogLevelError;

@implementation SFLogger

#pragma mark - Convenience Initialisers

+(instancetype)loggerWithDDLoggerInstance:(DDAbstractLogger <DDLogger> *)logger loggerLevel:(SFLoggerLogLevel)loggerLevel {
    
    return [[[self class] alloc] initWithDDLoggerInstance:logger loggerLevel:loggerLevel];
}

- (instancetype)initWithDDLoggerInstance:(DDAbstractLogger <DDLogger> *)logger loggerLevel:(SFLoggerLogLevel)loggerLevel {
    
    if (self = [super init]) {
        if (loggerLevel > SFLoggerLogLevelError && loggerLevel < SFLoggerLogLevelVerbose) {
            _loggerLevel = loggerLevel;
            ddLogLevel = (DDLogLevel)loggerLevel;
        } else {
            _loggerLevel = kDefaultLoggerLevel;
            ddLogLevel = (DDLogLevel)_loggerLevel;
        }
        if (logger) {
            _logger = logger;
            [DDLog addLogger:logger withLevel:(DDLogLevel)loggerLevel];
        } else {
            _logger = kDefaultLogger;
            [DDLog addLogger:_logger];
        }
    }
    
    return self;
}

- (instancetype)init {
    return [self initWithDDLoggerInstance:nil loggerLevel:-1];
}

#pragma mark - Public Methods

-(void)logError:(id)format, ... {
    va_list args;
    va_start(args, format);
    DDLogError(@"%@", [[NSString alloc] initWithFormat:format arguments:args]);
    va_end(args);
}

-(void)logDebug:(id)format, ... {
    va_list args;
    va_start(args, format);
    DDLogDebug(@"%@", [[NSString alloc] initWithFormat:format arguments:args]);
    va_end(args);
}

-(void)logVerbose:(id)format, ... {
    va_list args;
    va_start(args, format);
    DDLogVerbose(@"%@", [[NSString alloc] initWithFormat:format arguments:args]);
    va_end(args);
}

@end
