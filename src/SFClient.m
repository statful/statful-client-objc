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
// - Look at app tag
// - Look at flush_size and flush_interval
// - Add + Private in every class
// - Finish the tests
// - Configure the project for carthage too
// - system_stats

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
@property (strong, nonatomic) NSNumber *flushInterval;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSString *port;
@property (strong, nonatomic) NSNumber *sampleRate;
@property (strong, nonatomic) NSNumber *secure;
@property (strong, nonatomic) NSArray  *tags;
@property (strong, nonatomic) NSNumber *timeout;
@property (strong, nonatomic) NSString *token;
@property (assign, nonatomic) SFClientTransport transport;
@property (strong, nonatomic) NSString *namespace;
@property (strong, nonatomic) NSMutableDictionary *defaults;

@end

@implementation SFClient

#pragma mark - Convenience Initialisers

+(instancetype)clientWithConfig:(NSDictionary *)config {
    
    return [[[self class] alloc] initWithConfig:config];
}

- (instancetype)initWithConfig:(NSDictionary *)config {
    
    if (self = [super init]) {
        @try {
            [self validateAndSetConfig:config];
        }
        @catch(NSException* e) {
            return nil;
        }
    }
    return self;
}

- (instancetype)init {
    return [self initWithConfig:nil];
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
    NSDictionary *options = calculateConfig();
    [self counterWithName:name value:value options:options];
}

-(void)counterWithName:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options {
    [self putWithType:@"counter" name:name value:value options:options];
}

-(void)gaugeWithName:(NSString*)name value:(NSNumber*)value {
    NSDictionary *options = calculateConfig();
    [self gaugeWithName:name value:value options:options];
}

-(void)gaugeWithName:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options {
    [self putWithType:@"gauge" name:name value:value options:options];
}

-(void)timerWithName:(NSString*)name value:(NSNumber*)value {
    NSDictionary *options = calculateConfig();
    [self timerWithName:name value:value options:options];
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
    
    NSString *metric = [NSString stringWithFormat:@"%@.%@.%@%@ %@ %lu %@%@", options[@"namespace"], type, name, tags, value, [options[@"timestamp"] integerValue], aggs, options[@"agg_freq"]];
    
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

- (void)setDefaults:(NSDictionary *)defaults {
    _defaults = [[NSMutableDictionary alloc]initWithCapacity:kImplementedMethods.count];
    
    for (NSString* method in kImplementedMethods) {
        if (defaults[method]) {
            _defaults[method] = [[NSMutableDictionary alloc] init];
            
            if (defaults[method][@"tags"]) {
                _defaults[method][@"tags"] = defaults[method][@"tags"];
            }
            if (defaults[method][@"aggs"]) {
                _defaults[method][@"aggs"] = defaults[method][@"aggs"];
            }
            if (defaults[method][@"agg_freq"]) {
                _defaults[method][@"agg_freq"] = defaults[method][@"agg_freq"];
            }
        }
    }
}

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

-(void)validateAndSetConfig:(NSDictionary *)config {
    __block SFClient *blocksafeSelf = self;
    NSDictionary* propertiesRules = getPropertiesRules();
    
    // Logger
    [self setProperty:@"logger" fromConfig:config WithRules:propertiesRules[@"logger"] AndWithSetter:^(id value) {
        [blocksafeSelf setLogger:[[SFLogger alloc] initWithDDLoggerInstance:value loggerLevel:-1]];
    }];
    
    // Host
    [self setProperty:@"host" fromConfig:config WithRules:propertiesRules[@"host"] AndWithSetter:^(id value) {
        [blocksafeSelf setHost:value];
    }];
    
    // Port
    [self setProperty:@"port" fromConfig:config WithRules:propertiesRules[@"port"] AndWithSetter:^(id value) {
        [blocksafeSelf setPort:value];
    }];
    
    // Transport
    [self setProperty:@"transport" fromConfig:config WithRules:propertiesRules[@"transport"] AndWithSetter:^(id value) {
        [blocksafeSelf setTransport:[((NSNumber*)value) intValue]];
    }];
    
    // Secure
    [self setProperty:@"secure" fromConfig:config WithRules:propertiesRules[@"secure"] AndWithSetter:^(id value) {
        [blocksafeSelf setSecure:value];
    }];
    
    // Timeout
    [self setProperty:@"timeout" fromConfig:config WithRules:propertiesRules[@"timeout"] AndWithSetter:^(id value) {
        [blocksafeSelf setTimeout:value];
    }];
    
    // Token
    [self setProperty:@"token" fromConfig:config WithRules:propertiesRules[@"token"] AndWithSetter:^(id value) {
        [blocksafeSelf setToken:value];
    }];
    
    // App
    [self setProperty:@"app" fromConfig:config WithRules:propertiesRules[@"app"] AndWithSetter:^(id value) {
        [blocksafeSelf setApp:value];
    }];
    
    // Dryrun
    [self setProperty:@"dryrun" fromConfig:config WithRules:propertiesRules[@"dryrun"] AndWithSetter:^(id value) {
        [blocksafeSelf setDryrun:value];
    }];
    
    // Tags
    [self setProperty:@"tags" fromConfig:config WithRules:propertiesRules[@"tags"] AndWithSetter:^(id value) {
        [blocksafeSelf setTags:value];
    }];
    
    // Sample Rate
    [self setProperty:@"sample_rate" fromConfig:config WithRules:propertiesRules[@"sample_rate"] AndWithSetter:^(id value) {
        [blocksafeSelf setSampleRate:value];
    }];
    
    // Flush Size
    [self setProperty:@"flush_size" fromConfig:config WithRules:propertiesRules[@"flush_size"] AndWithSetter:^(id value) {
        [blocksafeSelf setFlushSize:value];
    }];
    
    // Flush Interval
    [self setProperty:@"flush_interval" fromConfig:config WithRules:propertiesRules[@"flush_interval"] AndWithSetter:^(id value) {
        [blocksafeSelf setFlushInterval:value];
    }];
    
    // Namespace
    [self setProperty:@"namespace" fromConfig:config WithRules:propertiesRules[@"namespace"] AndWithSetter:^(id value) {
        [blocksafeSelf setNamespace:value];
    }];
    
    // Defaults
    [self setProperty:@"defaults" fromConfig:config WithRules:propertiesRules[@"defaults"] AndWithSetter:^(id value) {
        [blocksafeSelf setDefaults:value];
    }];
    
    [self initTransportLayer];
}

#pragma mark - Private Methods

- (void)setProperty:(NSString *)property fromConfig:(NSDictionary *)config WithRules:(NSDictionary*)rules AndWithSetter:(void (^)(id value))setterFunction {
    
    if ([config objectForKey:property]) {
        setterFunction(config[property]);
    } else {
        if ([rules objectForKey:@"required"] && [rules[@"required"] isEqualTo:@YES]) {
            @throw [NSException exceptionWithName:@"SFClientConfigError" reason:@"Error on config." userInfo:nil];
        } else if ([rules objectForKey:@"default"]) {
            setterFunction(rules[@"default"]);
            [_logger logError:@"Property %@ doesn't exist on config. Default value '%@' was applied.", property, rules[@"default"]];
        }
    }
    
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

FOUNDATION_STATIC_INLINE NSDictionary* calculateConfig() {
    return calculateConfigWithOptions(nil);
}

FOUNDATION_STATIC_INLINE NSDictionary* calculateConfigWithOptions(NSDictionary* methodOptions) {
    return @{};
    /*return @{
                    @"tags" : tags ?: @{},
                    @"agg": aggs ?: @[],
                    @"agg_freq": kDefaultAggFreq ?: @10,
                    @"namespace": namespace ?: kDefaultNamespace,
                    @"timestamp": @([[NSDate date]timeIntervalSince1970])
                    };*/
}

FOUNDATION_STATIC_INLINE NSDictionary* getPropertiesRules() {
    
    return @{
             @"host": @{@"required":@NO, @"default":kDefaultHost},
             @"port": @{@"required":@NO, @"default":kDefaultPort},
             @"transport": @{@"required":@YES},
             @"secure": @{@"required":@NO, @"default":kDefaultSecure},
             @"timeout": @{@"required":@NO, @"default":kDefaultTimeout},
             @"token": @{@"required":@NO},
             @"app": @{@"required":@NO},
             @"dryrun": @{@"required":@NO, @"default":kDefaultDryrun},
             @"logger": @{@"required":@NO},
             @"tags": @{@"required":@NO, @"default":kDefaultTags},
             @"sample_rate": @{@"required":@NO, @"default":kDefaultSampleRate},
             @"namespace": @{@"required":@NO, @"default":kDefaultNamespace},
             @"flush_size": @{@"required":@NO, @"default":kDefaultFlushSize},
             @"flush_interval": @{@"required":@NO, @"default":kDefaultFlushInterval},
             @"defaults": @{@"required":@NO, @"default":kDefaultDefaults}
    };
}

/*FOUNDATION_STATIC_INLINE NSDictionary *defaultConfigs() {
    return @{};
}

FOUNDATION_STATIC_INLINE NSDictionary *createDefaultOptions(NSDictionary *tags, NSArray *aggs, NSNumber* aggFreq, NSString*namespace) {
    
    return @{
             @"tags" : tags ?: @{},
             @"agg": aggs ?: @[],
             @"agg_freq": kDefaultAggFreq ?: @10,
             @"namespace": namespace ?: kDefaultNamespace,
             @"timestamp": @([[NSDate date]timeIntervalSince1970])
    };
}*/

@end
