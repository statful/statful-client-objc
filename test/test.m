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
#import "../src/SFClient+Private.h"

@interface test : XCTestCase
@property(strong, nonatomic) SFClient* default_sfc;
@property(strong, nonatomic) SFClient* default_sfc_with_required;
@property(strong, nonatomic) SFClient* sf_client;
@property(strong, nonatomic) NSDictionary* sf_config;
@end

@implementation test

- (void)setUp {
    [super setUp];
    
    // Init default statful client
   _default_sfc = [[SFClient alloc]init];
    
    // Init a default statful client only with required attributes setted
    _default_sfc_with_required = [[SFClient alloc] initWithConfig:@{@"transport": @(SFClientTransportUDP)}];
    
    // Custom statful client configuration
    _sf_config = @{
                   @"app": @"statful",
                   @"defaults": @{},
                   @"dryrun" : [NSNumber numberWithBool:YES],
                   @"flush_size" : [NSNumber numberWithInt:10],
                   @"flush_interval" : [NSNumber numberWithInt:10],
                   @"host" : @"123.456.789.123",
                   @"logger": [DDTTYLogger sharedInstance],
                   @"port" : @"123",
                   @"sample_rate" : [NSNumber numberWithInt:50],
                   @"secure" : [NSNumber numberWithBool:NO],
                   @"tags": @{@"gt1":@"tag_1", @"gt1":@"tag_2"},
                   @"timeout": [NSNumber numberWithInt:1000],
                   @"token": @"statful-token",
                   @"transport": @(SFClientTransportUDP),
                   @"secure" : [NSNumber numberWithBool:NO],
                   @"namespace" : @"application"
                   };
    
    _sf_client = [SFClient clientWithConfig:_sf_config];
}

- (void)tearDown {
    [super tearDown];
    
}

- (void)testBuiltClass {
    XCTAssertNil(_default_sfc);
    XCTAssertTrue([_default_sfc_with_required isKindOfClass:[SFClient class]]);
    XCTAssertTrue([_sf_client isKindOfClass:[SFClient class]]);
}

- (void)testSampleRateRange {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    SFClient* badConfigSFClient;
    
    changedSFConfig[@"sample_rate"] = @0;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"sample_rate"] = @1;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    changedSFConfig[@"sample_rate"] = @100;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    changedSFConfig[@"sample_rate"] = @101;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
}

- (void)testRequiredConfigs {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    SFClient* badConfigSFClient;
    
    changedSFConfig[@"transport"] = nil;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    
    XCTAssertNil(badConfigSFClient);
}

- (void)testConfigsAttributeType {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    SFClient* badConfigSFClient;
    
    // Host
    changedSFConfig[@"host"] = @10;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"host"] = @"";
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    // Port
    changedSFConfig[@"port"] = @10;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"port"] = @"";
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    // Transport
    changedSFConfig[@"transport"] = @"";
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"transport"] = @(SFClientTransportUDP);
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    // Secure
    changedSFConfig[@"secure"] = @"";
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"secure"] = @NO;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    // Timeout
    changedSFConfig[@"timeout"] = @"";
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"timeout"] = @1000;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    // token
    changedSFConfig[@"token"] = @10;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"token"] = @"";
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    // App
    changedSFConfig[@"app"] = @10;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"app"] = @"";
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    // Dryrun
    changedSFConfig[@"dryrun"] = @"";
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"dryrun"] = @YES;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    //Logger
    changedSFConfig[@"logger"] = @"";
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"logger"] = [DDTTYLogger sharedInstance];
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    // Tags
    changedSFConfig[@"tags"] = @[];
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"tags"] = @{};
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    // Sample Rate
    changedSFConfig[@"sample_rate"] = @"";
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"sample_rate"] = @10;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    // Namespace
    changedSFConfig[@"namespace"] = @10;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"namespace"] = @"";
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    // Flush size
    changedSFConfig[@"flush_size"] = @"";
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"flush_size"] = @10;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    // Flush interval
    changedSFConfig[@"flush_interval"] = @"";
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"flush_interval"] = @10;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    // Defaults
    changedSFConfig[@"defaults"] = @"";
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"defaults"] = @{};
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
}

-(void)testConfigValuesPerDefault {
    XCTAssertEqual(_default_sfc_with_required.host, kDefaultHost);
    XCTAssertEqual(_default_sfc_with_required.port, kDefaultPort);
    XCTAssertEqual(_default_sfc_with_required.secure, kDefaultSecure);
    XCTAssertEqual(_default_sfc_with_required.timeout, kDefaultTimeout);
    XCTAssertEqual(_default_sfc_with_required.token, nil);
    XCTAssertEqual(_default_sfc_with_required.app, nil);
    XCTAssertEqual(_default_sfc_with_required.dryrun, kDefaultDryrun);
    XCTAssertEqual(_default_sfc_with_required.logger, nil);
    XCTAssert([_default_sfc_with_required.tags isEqualToDictionary:kDefaultGlobalTags]);
    XCTAssertEqual(_default_sfc_with_required.sampleRate, kDefaultSampleRate);
    XCTAssertEqual(_default_sfc_with_required.namespace, kDefaultNamespace);
    XCTAssertEqual(_default_sfc_with_required.flushSize, kDefaultFlushSize);
    XCTAssertEqual(_default_sfc_with_required.flushInterval, kDefaultFlushInterval);
    XCTAssert([_default_sfc_with_required.defaults isEqualToDictionary:kDefaultDefaults]);
}

-(void)testDefaultConfigValues {
    
}

/*
 - (void)testTimer {
 XCTAssertNil(_default_sfc);
 XCTAssertTrue([_sf_client isKindOfClass:[SFClient class]]);
 
 NSLog(@"timer time");
 
 NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow: 3.0 ];
 
 NSLog(@"about to wait");
 [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
 NSLog(@"wait time is over");
 
 [[NSRunLoop currentRunLoop] run];
 }
 
 // Make that work exposing SFClient.h+Private with private properties
 - (void)testDefaultConstructor {
    XCTAssertEqual(_default_sfc.host, @"127.0.0.1");
    XCTAssertEqual(_default_sfc.port, @"2013");
    XCTAssertEqual(_default_sfc.secure, @YES);
    XCTAssertEqual(_default_sfc.timeout, @2000);
    XCTAssertEqual(_default_sfc.dryrun, @NO);
    XCTAssertEqual(_default_sfc.tags, @[]);
    XCTAssertEqual(_default_sfc.sampleRate, @100);
    XCTAssertEqual(_default_sfc.flushSize, @10);
}

- (void)testCustomConstructor {
    XCTAssertEqual(_sf_client.app, @"statful");
    XCTAssertEqual(_sf_client.dryrun, @YES);
    XCTAssertEqual(_sf_client.flushSize, @12);
    XCTAssertEqual(_sf_client.host, @"123.456.789.123");
    XCTAssertEqual(_sf_client.port, @"123");
    XCTAssertEqual(_sf_client.sampleRate, @50);
    XCTAssertEqual(_sf_client.secure, @NO);
    XCTAssertEqual(_sf_client.timeout, @1000);
    XCTAssertEqual(_sf_client.token, @"statful-token");
    XCTAssertEqual(_sf_client.transport, SFClientTransportUDP);
    
    BOOL tags_arrays_compare_result = [_sf_client.tags isEqualToArray:@[@"tag_1", @"tag_2"]];
    XCTAssertEqual(tags_arrays_compare_result, true);
}*/

@end
