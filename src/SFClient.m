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

// TO-DO
// - Add default configs per method
// - Sanitize options (aggs, tags, etc)
// - Finish the tests
// - Configure the project for carthage too

#import "SFClient.h"

#import "SFCommunicationProtocol.h"
#import "SFCommunicationHTTP.h"
#import "SFCommunicationSocketTCP.h"
#import "SFCommunicationSocketUDP.h"
#import "SFConstants.h"

@interface SFClient ()

// Implementation related properties
@property (strong, nonatomic) id<SFCommunicationProtocol> connection;
@property (strong, nonatomic) NSMutableArray *metricsBuffer;
@property (strong, nonatomic) NSString *app;
@property (strong, nonatomic) NSNumber *dryrun;
@property (strong, nonatomic) NSNumber *flushSize;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSString *port;
@property (strong, nonatomic) NSNumber *sampleRate;
@property (strong, nonatomic) NSNumber *secure;
@property (strong, nonatomic) NSArray  *tags;
@property (strong, nonatomic) NSNumber *timeout;
@property (strong, nonatomic) NSString *token;
@property (assign, nonatomic) SFClientTransport transport;
@property (strong, nonatomic) NSString *namespace;
@property (strong, nonatomic) NSDictionary *defaults;

@end

@implementation SFClient

#pragma mark - Convenience Initialisers

+(instancetype)clientWithConfig:(NSDictionary *)config {
    
    return [[[self class] alloc] initWithConfig:config];
}

- (instancetype)initWithConfig:(NSDictionary *)config {
    
    if (self = [super init]) {
        
        // TODO: Why not move logic to this method, since this should be the default init
        // Also, this should be done. If configuration fails, we should use default Configs maybe, or throw exception. Class should use non_null initialisers
        if (![self validateAndSetConfig:config]) {
            // TODO: Need to work on this, if fails get another solution
            return nil;
        }
    }
    return self;
}

- (instancetype)init {
    return [self initWithConfig:defaultConfigs()];
}

- (void)initTransportLayer {
    NSDictionary *configs = @{@"host" : _host, @"port" : _port, @"timeout" : _timeout};
    __block BOOL successInit = YES;
    __block NSError* errorInit = nil;
    
    if (_transport == SFClientTransportTCP) {
        _connection = [[SFCommunicationSocketTCP alloc] initWithDictionary:configs completionBlock:^(BOOL success, NSError *error) {
            
            successInit = success;
            errorInit = error;
        }];
    } else if (_transport == SFClientTransportUDP) {
        _connection = [[SFCommunicationSocketUDP alloc] initWithDictionary:configs completionBlock:^(BOOL success, NSError *error) {
            
            successInit = success;
            errorInit = error;
        }];
    } else if (_transport == SFClientTransportAPI) {
        NSMutableDictionary *mutableConfigs = [configs mutableCopy];
        mutableConfigs[@"secure"] = _secure;
        mutableConfigs[@"token"] = _token;

        _connection = [[SFCommunicationHTTP alloc] initWithDictionary:[mutableConfigs copy] completionBlock:^(BOOL success, NSError *error) {
            
            successInit = success;
            errorInit = error;
        }];
    }
    
    if (successInit) {
        [_logger logDebug:@"Success initing transport layer."];
    } else {
        [_logger logError:@"Error initing transport layer: %@.", errorInit];
    }
}

#pragma mark - Public Methods

-(void)counterWithName:(NSString*)name value:(NSNumber*)value {
    
    NSDictionary *defaultOptions = createDefaultOptions(nil, @[@"avg", @"p90"], @10, _namespace);
    
    [self counterWithName:name value:value options:defaultOptions];
}

-(void)counterWithName:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options {
    [self putWithType:@"counter" name:name value:value options:options];
}

-(void)gaugeWithName:(NSString*)name value:(NSNumber*)value {
    
    NSDictionary *defaultOptions = createDefaultOptions(nil, @[@"last"], @10, _namespace);

    [self gaugeWithName:name value:value options:defaultOptions];
}

-(void)gaugeWithName:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options {
    [self putWithType:@"gauge" name:name value:value options:options];
}

-(void)timerWithName:(NSString*)name value:(NSNumber*)value {
    NSDictionary *defaultOptions = createDefaultOptions(@{@"unit":@"ms"}, @[@"avg", @"p90", @"count"], @10, _namespace);
    
    [self timerWithName:name value:value options:defaultOptions];
}

-(void)timerWithName:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options {
    [self putWithType:@"timer" name:name value:value options:options];
}

-(NSString*)metricBuilderWithType:(NSString*)type name:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options {
    NSMutableString *tags = [[NSMutableString alloc] init];
    NSMutableString *aggs = [[NSMutableString alloc] init];
    NSDictionary *tags_in_dict = options[@"tags"];
    NSDictionary *aggs_in_dict = options[@"aggs"];
    
    for (NSString* key in tags_in_dict) {
        NSString* value = [tags_in_dict objectForKey:key];
        [tags appendString:[NSString stringWithFormat:@",%@=%@",key,value]];
    }
    
    for (NSString* key in aggs_in_dict) {
        NSString* value = [aggs_in_dict objectForKey:key];
        [aggs appendString:[NSString stringWithFormat:@"%@=%@,",key,value]];
    }
    
    NSString *metric = [NSString stringWithFormat:@"%@.%@.%@%@ %@ %@ %@%@", options[@"namespace"], type, name, tags, value, options[@"timestamp"], aggs, options[@"agg_freq"]];
    
    return metric;
}

-(void)putRawWithType:(NSString*)type name:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options {
    NSString* metric = [self metricBuilderWithType:type name:name value:value options:options];
    [self.metricsBuffer addObject:metric];
    [self flushBuffer];
}

-(void)putWithType:(NSString*)type name:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options {
    double sampleRateNormalized = [self.sampleRate doubleValue] / 100.0;
    double randomRate = (arc4random() % (100)) * 0.01;
    
    if (randomRate <= sampleRateNormalized) {
        [self putRawWithType:type name:name value:value options:options];
    }
}

#pragma mark - Properties setters

- (void)setSampleRate:(NSNumber *)sampleRate {
    if ([sampleRate intValue] > 0 && [sampleRate intValue] < 101) {
        _sampleRate = sampleRate;
    } else {
        [_logger logError:@"Sample rate must be in rage [1, 100]."];
    }
}

-(void)setTransport:(SFClientTransport)transport {
    if (transport == SFClientTransportUDP || transport == SFClientTransportAPI) {
        _transport = transport;
    } else {
        [_logger logError:@"Transport must be SFClientTransportUDP or SFClientTransportAPI."];
    }
}

-(BOOL)validateAndSetConfig:(NSDictionary *)config {
    __block SFClient *blocksafeSelf = self;
    
    // Host
    [self setProperty:@"host" fromConfig:config withSetter:^(id value) {
        [blocksafeSelf setHost:value];
    }];
    
    // Port
    [self setProperty:@"port" fromConfig:config withSetter:^(id value) {
        [blocksafeSelf setPort:value];
    }];
    
    // Transport
    [self setProperty:@"transport" fromConfig:config withSetter:^(id value) {
        [blocksafeSelf setTransport:[((NSNumber*)value) intValue]];
    }];
    
    // Secure
    [self setProperty:@"secure" fromConfig:config withSetter:^(id value) {
        [blocksafeSelf setSecure:value];
    }];
    
    // Timeout
    [self setProperty:@"timeout" fromConfig:config withSetter:^(id value) {
        [blocksafeSelf setTimeout:value];
    }];
    
    // Token
    [self setProperty:@"token" fromConfig:config withSetter:^(id value) {
        [blocksafeSelf setToken:value];
    }];
    
    // App
    [self setProperty:@"app" fromConfig:config withSetter:^(id value) {
        [blocksafeSelf setApp:value];
    }];
    
    // Dryrun
    [self setProperty:@"dryrun" fromConfig:config withSetter:^(id value) {
        [blocksafeSelf setDryrun:value];
    }];
    
    // Tags
    [self setProperty:@"tags" fromConfig:config withSetter:^(id value) {
        [blocksafeSelf setTags:value];
    }];
    
    // Sample Rate
    [self setProperty:@"sample_rate" fromConfig:config withSetter:^(id value) {
        [blocksafeSelf setSampleRate:value];
    }];
    
    // Flush Size
    [self setProperty:@"flush_size" fromConfig:config withSetter:^(id value) {
        [blocksafeSelf setFlushSize:value];
    }];
    
    // Logger
    [self setProperty:@"logger" fromConfig:config withSetter:^(id value) {
        [blocksafeSelf setLogger:[[SFLogger alloc] initWithDDLoggerInstance:value loggerLevel:-1]];
    }];
    
    // Namespace
    [self setProperty:@"namespace" fromConfig:config withSetter:^(id value) {
        [blocksafeSelf setNamespace:value];
    }];
    
    // Defaults
    [self setProperty:@"defaults" fromConfig:config withSetter:^(id value) {
        [blocksafeSelf setDefaults:value];
    }];
    
    [self initTransportLayer];
    
    return YES;
}

#pragma mark - Private Methods

- (BOOL)setProperty:(NSString *)property fromConfig:(NSDictionary *)config withSetter:(void (^)(id value))setterFunction {
    if (config[property] != nil) {
        setterFunction(config[property]);
    } else {
        [_logger logError:@"Property %@ doesn't exist on config.", property];
        return NO;
    }
    return YES;
}

-(void)flushBuffer {
    if (self.metricsBuffer.count >= self.flushSize.intValue) {
        NSString *metricsToFlush = [self.metricsBuffer componentsJoinedByString:@"\n"];
        
        [self flushMetrics:metricsToFlush];
        
        [self.metricsBuffer removeAllObjects];
    }
}

-(void)flushMetrics:(NSString*)metrics {
    if (self.dryrun) {
        [_logger logDebug:@"%@",metrics];
    } else {
        NSData *metricsData = [metrics dataUsingEncoding:NSUTF8StringEncoding];
        [self.connection sendMetricsData:metricsData completionBlock:^(BOOL success, NSError *error) {
            if (success) {
                [_logger logDebug:@"Metrics were flushed successfully."];
            } else {
                [_logger logError:@"An error has happened during metrics flush: %@.", error];
            }
        }];
    }
}

FOUNDATION_STATIC_INLINE NSDictionary *defaultConfigs() {
    
    return @{
             @"host" : @"127.0.0.1",
             @"port" : @"2013",
             @"secure" : @YES,
             @"timeout" : @2000,
             @"dryrun" : @NO,
             @"tags" : @[],
             @"sample_rate" : @100,
             @"flush_size" : @10,
             @"logger" : [DDTTYLogger sharedInstance]
    };
}

FOUNDATION_STATIC_INLINE NSDictionary *createDefaultOptions(NSDictionary *tags, NSArray *aggs, NSNumber* aggFreq, NSString* namespace) {
    
    NSLog(@"%@", kDefaultAggFreq);
    return @{
             @"tags" : tags ?: @{},
             @"agg": aggs ?: @[],
             @"agg_freq": kDefaultAggFreq ? kDefaultAggFreq : @10,
             @"namespace": namespace ?: kDefaultNamespace,
             @"timestamp": @([[NSDate date]timeIntervalSince1970])
    };
}

@end
