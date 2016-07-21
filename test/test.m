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
#import "../src/SFClient.h"

@interface test : XCTestCase
@property(strong, nonatomic) SFClient* default_sfc;
@property(strong, nonatomic) SFClient* sf_client;
@property(strong, nonatomic) NSDictionary* sf_config;
@end

@implementation test

- (void)setUp {
    [super setUp];
    
    // Init default statful client
    _default_sfc = [[SFClient alloc]init];
    
    // Custom statful client configuration
    _sf_config = @{
                   @"app": @"statful",
                   @"dryrun" : [NSNumber numberWithBool:YES],
                   @"flush_size" : [NSNumber numberWithInt:12],
                   @"host" : @"123.456.789.123",
                   @"port" : @"123",
                   @"sample_rate" : [NSNumber numberWithInt:50],
                   @"secure" : [NSNumber numberWithBool:NO],
                   @"tags": @[@"tag_1", @"tag_2"],
                   @"timeout": [NSNumber numberWithInt:1000],
                   @"token": @"statful-token",
                   @"transport": [NSNumber numberWithInt:SFClientTransportUDP]
                   };
    
    _sf_client = [SFClient clientWithConfig:_sf_config];
}

- (void)tearDown {
    [super tearDown];
    
}

- (void)testBuiltClass {
    XCTAssertTrue([_default_sfc isKindOfClass:[SFClient class]]);
    XCTAssertTrue([_sf_client isKindOfClass:[SFClient class]]);
}

@end
