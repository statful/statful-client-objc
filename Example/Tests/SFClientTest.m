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

@import XCTest;
#import <StatfulClient/SFClient.h>
#import <StatfulClient/SFClient+Private.h>

@interface SFClientTest : XCTestCase
@property(strong, nonatomic) SFClient* default_sfc;
@property(strong, nonatomic) SFClient* default_sfc_with_required;
@property(strong, nonatomic) SFClient* sf_client;
@property(strong, nonatomic) SFClient* sf_client_instance_constructor;
@property(strong, nonatomic) NSDictionary* sf_config;
@end

@implementation SFClientTest

- (void)setUp {
    [super setUp];
    
    // Init default statful client
   _default_sfc = [[SFClient alloc]init];
    
    // Init a default statful client only with required attributes setted
    _default_sfc_with_required = [[SFClient alloc] initWithConfig:@{@"transport": @(SFClientTransportUDP)}];
    
    // Custom statful client configuration
    _sf_config = @{
                   
                   @"defaults": @{},
                   @"dryrun" : @YES,
                   @"flush_size" : @10,
                   @"flush_interval" : @10,
                   @"host" : @"123.456.789.123",
                   @"logger": [DDTTYLogger sharedInstance],
                   @"port" : @"123",
                   @"sample_rate" : @100,
                   @"secure" : @NO,
                   @"tags": @{@"gt1":@"tag_1"},
                   @"timeout": @1000,
                   @"token": @"statful-token",
                   @"transport": @(SFClientTransportUDP),
                   @"secure" : @NO,
                   @"namespace" : @"application"
                   };
    
    _sf_client = [SFClient clientWithConfig:_sf_config];
    _sf_client_instance_constructor = [[SFClient alloc] initWithConfig:_sf_config];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBuiltClass {
    XCTAssertNil(_default_sfc);
    XCTAssertTrue([_default_sfc_with_required isKindOfClass:[SFClient class]]);
    XCTAssertTrue([_sf_client isKindOfClass:[SFClient class]]);
    XCTAssertTrue([_sf_client_instance_constructor isKindOfClass:[SFClient class]]);
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
    
    changedSFConfig[@"flush_size"] = @0;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"flush_size"] = @10;
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    // Flush interval
    changedSFConfig[@"flush_interval"] = @"";
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    changedSFConfig[@"flush_interval"] = @0;
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
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    SFClient* badConfigSFClient;
    
    // Invalid Tags
    changedSFConfig[@"defaults"] = @{@"timer":@{@"tags":@[]
                                            }
                                    };
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    // Valid Tags
    changedSFConfig[@"defaults"] = @{@"timer":@{@"tags":@{@"gt1":@"t1"}
                                                }
                                     };
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    // Invalid Aggs
    changedSFConfig[@"defaults"] = @{@"timer":@{@"agg":@{}
                                                }
                                     };
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    // Invalid Aggs
    changedSFConfig[@"defaults"] = @{@"timer":@{@"agg":@[@"null_Agg"]
                                                }
                                     };
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    // Valid Agg
    changedSFConfig[@"defaults"] = @{@"timer":@{@"agg":@[@"last"]
                                                }
                                     };
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    // Invalid AggFreq
    changedSFConfig[@"defaults"] = @{@"timer":@{@"agg_freq":@{}
                                                }
                                     };
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    // Valid AggFreq
    changedSFConfig[@"defaults"] = @{@"timer":@{@"agg_freq":@10
                                                }
                                     };
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    changedSFConfig[@"defaults"] = @{@"timer":@{@"agg_freq":@30
                                                }
                                     };
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    changedSFConfig[@"defaults"] = @{@"timer":@{@"agg_freq":@60
                                                }
                                     };
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    changedSFConfig[@"defaults"] = @{@"timer":@{@"agg_freq":@120
                                                }
                                     };
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    changedSFConfig[@"defaults"] = @{@"timer":@{@"agg_freq":@180
                                                }
                                     };
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    changedSFConfig[@"defaults"] = @{@"timer":@{@"agg_freq":@300
                                                }
                                     };
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    // Valid Defaults Output
    changedSFConfig[@"defaults"] = @{@"timer":@{@"tags":@{@"gt1":@"t1"},
                                                @"agg":kSupportedAgg,
                                                @"agg_freq": @300},
                                     @"invalidAgg":@{@"agg": kSupportedAgg}
                                     };
    badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNotNil(badConfigSFClient);
    
    NSDictionary *finalExpectedDictionary = @{@"timer":@{@"tags":@{@"gt1":@"t1"},
                                                         @"agg":kSupportedAgg,
                                                         @"agg_freq": @300}};
    XCTAssert([badConfigSFClient.defaults isEqualToDictionary:finalExpectedDictionary]);

}

-(void)testCurrentTimestamp {
    NSString* currentTimestamp = [NSString stringWithFormat:@"%lu", [@([[NSDate date] timeIntervalSince1970]) integerValue]];
    BOOL assertCurrentTimestamp = [currentTimestamp isEqualToString:CURRENT_TIMESTAMP];
    XCTAssert(assertCurrentTimestamp);
}

-(void)testStart {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"transport"] = nil;
    SFClient* badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    XCTAssertNotNil(_sf_client);
    XCTAssertFalse(_sf_client.isStarted);
    XCTAssertTrue(_sf_client.isConfigValid);
    
    [_sf_client timerWithName:@"testTimer" value:@0];
    XCTAssertEqual(_sf_client.metricsBuffer.count, 1);
    
    [_sf_client start];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:([_sf_client.flushInterval floatValue]/1000.0f)];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    XCTAssertEqual(_sf_client.metricsBuffer.count, 0);
    XCTAssertTrue(_sf_client.isStarted);
    XCTAssertTrue(_sf_client.flushTimer.isValid);
    
    [_sf_client stop];
}

-(void)testStop {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"transport"] = nil;
    SFClient* badConfigSFClient = [SFClient clientWithConfig:changedSFConfig];
    XCTAssertNil(badConfigSFClient);
    
    XCTAssertNotNil(_sf_client);
    XCTAssertFalse(_sf_client.isStarted);
    XCTAssertTrue(_sf_client.isConfigValid);
    
    [_sf_client start];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:([_sf_client.flushInterval floatValue]/1000.0f)];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    [_sf_client timerWithName:@"testTimer" value:@0];
    XCTAssertEqual(_sf_client.metricsBuffer.count, 1);
    
    [_sf_client stop];
    XCTAssertEqual(_sf_client.metricsBuffer.count, 0);
    XCTAssertFalse(_sf_client.isStarted);
    XCTAssertFalse(_sf_client.flushTimer.isValid);
    
}

-(void)testInitTransport {
    [_sf_client start];
    XCTAssert([_sf_client.connection isKindOfClass:[SFCommunicationSocketUDP class]]);
    [_sf_client stop];
    
    
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"transport"] = @(SFClientTransportAPI);
    SFClient* changedSFClient = [SFClient clientWithConfig:changedSFConfig];
    
    
    [changedSFClient start];
    XCTAssert([changedSFClient.connection isKindOfClass:[SFCommunicationHTTP class]]);
    [changedSFClient stop];
}

-(void)testCounterMethod {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"flush_interval"] = @500;
    SFClient* changedSFClient = [SFClient clientWithConfig:changedSFConfig];
    
    [changedSFClient start];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:([changedSFClient.flushInterval floatValue]/1000.0f)];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    [changedSFClient counterWithName:@"testCounter" value:@0];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 1);
    
    [changedSFClient counterWithName:@"testCounter" value:@0 options:nil];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 2);
    
    NSString* generatedMetric1 = [changedSFClient.metricsBuffer objectAtIndex:0];
    NSString* generatedMetric2 = [changedSFClient.metricsBuffer objectAtIndex:1];
    XCTAssert([generatedMetric1 isEqualToString:generatedMetric2]);
    
    
    XCTAssert([[[generatedMetric1 componentsSeparatedByString:@"."] objectAtIndex:1] isEqualToString:@"counter"]);
    XCTAssert([[[generatedMetric2 componentsSeparatedByString:@"."] objectAtIndex:1] isEqualToString:@"counter"]);
    
    [changedSFClient stop];
}

-(void)testGaugeMethod {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"flush_interval"] = @500;
    SFClient* changedSFClient = [SFClient clientWithConfig:changedSFConfig];
    
    [changedSFClient start];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:([changedSFClient.flushInterval floatValue]/1000.0f)];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    [changedSFClient gaugeWithName:@"testGauge" value:@0];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 1);
    
    [changedSFClient gaugeWithName:@"testGauge" value:@0 options:nil];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 2);
    
    NSString* generatedMetric1 = [changedSFClient.metricsBuffer objectAtIndex:0];
    NSString* generatedMetric2 = [changedSFClient.metricsBuffer objectAtIndex:1];
    XCTAssert([generatedMetric1 isEqualToString:generatedMetric2]);
    
    
    XCTAssert([[[generatedMetric1 componentsSeparatedByString:@"."] objectAtIndex:1] isEqualToString:@"gauge"]);
    XCTAssert([[[generatedMetric2 componentsSeparatedByString:@"."] objectAtIndex:1] isEqualToString:@"gauge"]);
    
    [changedSFClient stop];
}

-(void)testTimerMethod {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"flush_interval"] = @500;
    SFClient* changedSFClient = [SFClient clientWithConfig:changedSFConfig];
    
    [changedSFClient start];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:([changedSFClient.flushInterval floatValue]/1000.0f)];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    [changedSFClient timerWithName:@"testTimer" value:@0];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 1);
    
    [changedSFClient timerWithName:@"testTimer" value:@0 options:nil];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 2);
    
    NSString* generatedMetric1 = [changedSFClient.metricsBuffer objectAtIndex:0];
    NSString* generatedMetric2 = [changedSFClient.metricsBuffer objectAtIndex:1];
    XCTAssert([generatedMetric1 isEqualToString:generatedMetric2]);
    
    
    XCTAssert([[[generatedMetric1 componentsSeparatedByString:@"."] objectAtIndex:1] isEqualToString:@"timer"]);
    XCTAssert([[[generatedMetric2 componentsSeparatedByString:@"."] objectAtIndex:1] isEqualToString:@"timer"]);
    
    [changedSFClient stop];
}

-(void)testBaseMetricMethodAllDefaults {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"flush_interval"] = @100;
    changedSFConfig[@"tags"] = @{};
    SFClient* changedSFClient = [SFClient clientWithConfig:changedSFConfig];
    NSString* timestampToSet = @"123";
    
    [changedSFClient start];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:([changedSFClient.flushInterval floatValue]/1000.0f)];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    // Test for invalid type
    [changedSFClient methodWithType:@"unknownType" name:@"testUnkownType" value:@0 options:nil];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 0);
    
    // Test for invalid options
    [changedSFClient methodWithType:@"timer" name:@"testTimer" value:@0 options:@{@"tags":@[]}];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 0);
    [changedSFClient methodWithType:@"timer" name:@"testTimer" value:@0 options:@{@"agg":@{}}];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 0);
    [changedSFClient methodWithType:@"timer" name:@"testTimer" value:@0 options:@{@"agg_freq":@0}];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 0);
    
    // Test a valid method call: all defaults
    [changedSFClient methodWithType:@"timer" name:@"testTimer" value:@0 options:@{@"timestamp": timestampToSet}];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 1);
    XCTAssert([changedSFClient.metricsBuffer[0] isEqualToString:@"application.timer.testTimer,unit=ms 0 123 avg,p90,count,10"]);
    
    [changedSFClient stop];
}

-(void)testBaseMetricMethodWithApp {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"flush_interval"] = @100;
    changedSFConfig[@"tags"] = @{};
    changedSFConfig[@"app"] = @"statful";
    SFClient* changedSFClient = [SFClient clientWithConfig:changedSFConfig];
    NSString* timestampToSet = @"123";
    
    [changedSFClient start];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:([changedSFClient.flushInterval floatValue]/1000.0f)];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    // Test app option
    [changedSFClient methodWithType:@"timer" name:@"testTimer" value:@0 options:@{@"timestamp": timestampToSet}];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 1);
    XCTAssert([changedSFClient.metricsBuffer[0] isEqualToString:@"application.timer.testTimer,app=statful,unit=ms 0 123 avg,p90,count,10"]);
    
    [changedSFClient stop];
}

-(void)testBaseMetricMethodWithAppAndGeneralTags {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"flush_interval"] = @100;
    changedSFConfig[@"app"] = @"statful";
    SFClient* changedSFClient = [SFClient clientWithConfig:changedSFConfig];
    NSString* timestampToSet = @"123";
    
    [changedSFClient start];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:([changedSFClient.flushInterval floatValue]/1000.0f)];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    // Test app option
    [changedSFClient methodWithType:@"timer" name:@"testTimer" value:@0 options:@{@"timestamp": timestampToSet}];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 1);
    XCTAssert([changedSFClient.metricsBuffer[0] isEqualToString:@"application.timer.testTimer,gt1=tag_1,app=statful,unit=ms 0 123 avg,p90,count,10"]);
    
    [changedSFClient stop];
}

-(void)testBaseMetricMethodWithAppAndGeneralTagsAndPassedTag {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"flush_interval"] = @100;
    changedSFConfig[@"app"] = @"statful";
    SFClient* changedSFClient = [SFClient clientWithConfig:changedSFConfig];
    NSString* timestampToSet = @"123";
    NSDictionary* tagsToPass = @{@"passed_tag_1": @"1"};
    
    [changedSFClient start];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:([changedSFClient.flushInterval floatValue]/1000.0f)];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    // Test app option
    [changedSFClient methodWithType:@"timer" name:@"testTimer" value:@0 options:@{@"tags": tagsToPass, @"timestamp": timestampToSet}];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 1);
    XCTAssert([changedSFClient.metricsBuffer[0] isEqualToString:@"application.timer.testTimer,app=statful,gt1=tag_1,unit=ms,passed_tag_1=1 0 123 avg,p90,count,10"]);
    
    [changedSFClient stop];
}


-(void)testBaseMetricMethodWithAppAndGeneralTagsAndGeneralDefaultTags {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"flush_interval"] = @100;
    changedSFConfig[@"app"] = @"statful";
    changedSFConfig[@"defaults"] = @{@"timer": @{@"tags": @{@"g_default_tag": @"1"}}};
    SFClient* changedSFClient = [SFClient clientWithConfig:changedSFConfig];
    NSString* timestampToSet = @"123";
    
    [changedSFClient start];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:([changedSFClient.flushInterval floatValue]/1000.0f)];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    // Test app option
    [changedSFClient methodWithType:@"timer" name:@"testTimer" value:@0 options:@{@"timestamp": timestampToSet}];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 1);
    XCTAssert([changedSFClient.metricsBuffer[0] isEqualToString:@"application.timer.testTimer,gt1=tag_1,app=statful,g_default_tag=1 0 123 avg,p90,count,10"]);
    
    [changedSFClient stop];
}

-(void)testBaseMetricMethodWithAppAndGeneralTagsAndGeneralDefaultsAndPassedTags {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"flush_interval"] = @100;
    changedSFConfig[@"app"] = @"statful";
    changedSFConfig[@"defaults"] = @{@"timer": @{@"tags": @{@"g_default_tag": @"1"}}};
    NSDictionary* tagsToPass = @{@"passed_tag_1": @"1"};
    SFClient* changedSFClient = [SFClient clientWithConfig:changedSFConfig];
    NSString* timestampToSet = @"123";
    
    [changedSFClient start];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:([changedSFClient.flushInterval floatValue]/1000.0f)];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    // Test app option
    [changedSFClient methodWithType:@"timer" name:@"testTimer" value:@0 options:@{@"tags":tagsToPass, @"timestamp": timestampToSet}];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 1);
    XCTAssert([changedSFClient.metricsBuffer[0] isEqualToString:@"application.timer.testTimer,app=statful,g_default_tag=1,gt1=tag_1,passed_tag_1=1 0 123 avg,p90,count,10"]);
    
    [changedSFClient stop];
}

-(void)testBaseMetricMethodWithAppAndGeneralTagsAndGeneralDefaultsAndPassedTagsOverride {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"flush_interval"] = @100;
    changedSFConfig[@"app"] = @"statful";
    changedSFConfig[@"defaults"] = @{@"timer": @{@"tags": @{@"override_tag": @"1"}}};
    NSDictionary* tagsToPass = @{@"override_tag": @"2"};
    SFClient* changedSFClient = [SFClient clientWithConfig:changedSFConfig];
    NSString* timestampToSet = @"123";
    
    [changedSFClient start];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:([changedSFClient.flushInterval floatValue]/1000.0f)];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    // Test app option
    [changedSFClient methodWithType:@"timer" name:@"testTimer" value:@0 options:@{@"tags":tagsToPass, @"timestamp": timestampToSet}];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 1);
    XCTAssert([changedSFClient.metricsBuffer[0] isEqualToString:@"application.timer.testTimer,gt1=tag_1,app=statful,override_tag=2 0 123 avg,p90,count,10"]);
    
    [changedSFClient stop];
}

-(void)testBaseMetricMethodWithAggFreqWithoutAgg {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"flush_interval"] = @100;
    changedSFConfig[@"app"] = @"statful";
    changedSFConfig[@"defaults"] = @{@"timer": @{@"agg": @[]}};
    SFClient* changedSFClient = [SFClient clientWithConfig:changedSFConfig];
    NSString* timestampToSet = @"123";
    
    [changedSFClient start];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:([changedSFClient.flushInterval floatValue]/1000.0f)];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    // Test app option
    [changedSFClient methodWithType:@"timer" name:@"testTimer" value:@0 options:@{@"agg":@[], @"timestamp": timestampToSet}];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 1);
    XCTAssert([changedSFClient.metricsBuffer[0] isEqualToString:@"application.timer.testTimer,gt1=tag_1,app=statful,unit=ms 0 123"]);
    
    [changedSFClient stop];
}

-(void)testBaseMetricMethodWithAggFreq {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"flush_interval"] = @100;
    changedSFConfig[@"app"] = @"statful";
    SFClient* changedSFClient = [SFClient clientWithConfig:changedSFConfig];
    NSString* timestampToSet = @"123";
    
    [changedSFClient start];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:([changedSFClient.flushInterval floatValue]/1000.0f)];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    // Test app option
    [changedSFClient methodWithType:@"timer" name:@"testTimer" value:@0 options:@{@"agg_freq":@60, @"timestamp": timestampToSet}];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 1);
    XCTAssert([changedSFClient.metricsBuffer[0] isEqualToString:@"application.timer.testTimer,gt1=tag_1,app=statful,unit=ms 0 123 avg,p90,count,60"]);
    
    [changedSFClient stop];
}

-(void)testBaseMetricMethodWithAppAndGeneralDefaultAgg {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"flush_interval"] = @100;
    changedSFConfig[@"app"] = @"statful";
    changedSFConfig[@"defaults"] = @{@"timer": @{@"agg": @[@"last"]}};
    SFClient* changedSFClient = [SFClient clientWithConfig:changedSFConfig];
    NSString* timestampToSet = @"123";
    
    [changedSFClient start];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:([changedSFClient.flushInterval floatValue]/1000.0f)];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    // Test app option
    [changedSFClient methodWithType:@"timer" name:@"testTimer" value:@0 options:@{@"timestamp": timestampToSet}];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 1);
    XCTAssert([changedSFClient.metricsBuffer[0] isEqualToString:@"application.timer.testTimer,gt1=tag_1,app=statful,unit=ms 0 123 last,10"]);
    
    [changedSFClient stop];
}

-(void)testBaseMetricMethodWithAppAndGeneralDefaultAggAndPassedAgg {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"flush_interval"] = @100;
    changedSFConfig[@"app"] = @"statful";
    changedSFConfig[@"defaults"] = @{@"timer": @{@"agg": @[@"last"]}};
    NSArray* aggsToPass = @[@"count"];
    SFClient* changedSFClient = [SFClient clientWithConfig:changedSFConfig];
    NSString* timestampToSet = @"123";
    
    [changedSFClient start];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:([changedSFClient.flushInterval floatValue]/1000.0f)];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    // Test app option
    [changedSFClient methodWithType:@"timer" name:@"testTimer" value:@0 options:@{@"agg":aggsToPass, @"timestamp": timestampToSet}];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 1);
    XCTAssert([changedSFClient.metricsBuffer[0] isEqualToString:@"application.timer.testTimer,gt1=tag_1,app=statful,unit=ms 0 123 count,last,10"]);
    
    [changedSFClient stop];
}

-(void)testBaseMetricMethodWithAppAndEqualsGeneralDefaultAggAndPassedAgg {
    NSMutableDictionary* changedSFConfig = [NSMutableDictionary dictionaryWithDictionary:_sf_config];
    changedSFConfig[@"flush_interval"] = @100;
    changedSFConfig[@"app"] = @"statful";
    changedSFConfig[@"defaults"] = @{@"timer": @{@"agg": @[@"count"]}};
    NSArray* aggsToPass = @[@"count"];
    SFClient* changedSFClient = [SFClient clientWithConfig:changedSFConfig];
    NSString* timestampToSet = @"123";
    
    [changedSFClient start];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:([changedSFClient.flushInterval floatValue]/1000.0f)];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
    
    // Test app option
    [changedSFClient methodWithType:@"timer" name:@"testTimer" value:@0 options:@{@"agg":aggsToPass, @"timestamp": timestampToSet}];
    XCTAssertEqual(changedSFClient.metricsBuffer.count, 1);
    XCTAssert([changedSFClient.metricsBuffer[0] isEqualToString:@"application.timer.testTimer,gt1=tag_1,app=statful,unit=ms 0 123 count,10"]);
    
    [changedSFClient stop];
}

@end
