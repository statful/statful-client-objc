//
//  Copyright (c) 2015 Mindera
//  http://www.mindera.com/
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

#import <XCTest/XCTest.h>
#import "../src/Logger/SFLogger.h"

@interface SFLoggerTest : XCTestCase
@property(strong, nonatomic) SFLogger* default_sfl;
@property(strong, nonatomic) SFLogger* sf_logger;
@end

@implementation SFLoggerTest

- (void)setUp {
    [super setUp];
    
    _default_sfl = [[SFLogger alloc]init];
    _sf_logger = [SFLogger loggerWithDDLoggerInstance:[DDTTYLogger sharedInstance] loggerLevel:-1];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBuiltClass {
    XCTAssertTrue([_default_sfl isKindOfClass:[SFLogger class]]);
    XCTAssertTrue([_sf_logger isKindOfClass:[SFLogger class]]);
    
    _sf_logger = [[SFLogger alloc] initWithDDLoggerInstance:[DDTTYLogger sharedInstance] loggerLevel:-1];
    XCTAssertTrue([_sf_logger isKindOfClass:[SFLogger class]]);
}

- (void)testDefaultConstructor {
    XCTAssertTrue([_default_sfl.logger isKindOfClass:[kDefaultLogger class]]);
    XCTAssertTrue(_default_sfl.loggerLevel == kDefaultLoggerLevel);
}

- (void)testConstructorParamsThatGeneratesDefaults {
    _sf_logger = [SFLogger loggerWithDDLoggerInstance:nil loggerLevel:-1];
    XCTAssertTrue([_sf_logger.logger isKindOfClass:[kDefaultLogger class]]);
    XCTAssertTrue(_sf_logger.loggerLevel == kDefaultLoggerLevel);
    
    _sf_logger = [SFLogger loggerWithDDLoggerInstance:(DDAbstractLogger*)[NSArray arrayWithObject:@"sd"]
                                          loggerLevel:1000];
    XCTAssertTrue([_sf_logger.logger isKindOfClass:[kDefaultLogger class]]);
    XCTAssertTrue(_sf_logger.loggerLevel == kDefaultLoggerLevel);
}

- (void)testCustomConstructorParams {
    _sf_logger = [SFLogger loggerWithDDLoggerInstance:[DDASLLogger sharedInstance] loggerLevel:SFLoggerLogLevelDebug];
    XCTAssertTrue([_sf_logger.logger isKindOfClass:[DDASLLogger class]]);
    XCTAssertTrue(_sf_logger.loggerLevel == SFLoggerLogLevelDebug);
}

@end
