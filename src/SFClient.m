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

// TODO: Review this points
// - Finish the tests
// - Add + Private as needed for unit tests
// - Configure the project for carthage too
// - Public Documentation
// - Later on add some system stats automatically

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
@property (strong, nonatomic) NSTimer *flushTimer;

@end

@implementation SFClient

#pragma mark - Convenience Initialisers

+ (instancetype)clientWithConfig:(NSDictionary *)config {
    
    return [[[self class] alloc] initWithConfig:config];
}

- (instancetype)initWithConfig:(NSDictionary *)config {
    
    if (self = [super init]) {
        _isStarted = NO;
        _isConfigCorrect = NO;
        
        @try {
            [self validateAndSetConfig:config];
        }
        @catch(NSException* e) {
            _isStarted = NO;
            _isConfigCorrect = NO;
            [_logger logError:e.reason];
            
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
        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:[NSString stringWithFormat:@"Error initing transport layer: %@.", errorInit] userInfo:nil];
    }
}

-(void)initFlushTimer {
    _flushTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(flushBufferWithTimer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_flushTimer forMode:NSDefaultRunLoopMode];
}

-(BOOL)start {
    BOOL startedSucessfuly = NO;
    
    if (!_isStarted) {
        if (_isConfigCorrect) {
            @try {
                [self initTransportLayer];
                [self initFlushTimer];
                [[NSRunLoop currentRunLoop] run];
                
                _isStarted = YES;
                startedSucessfuly = YES;
                [_logger logDebug:@"Client was started."];
            } @catch(NSException* e) {
                [_logger logError:e.reason];
            }
        } else {
            [_logger logDebug:@"Client config is not valid."];
        }
    } else {
        [_logger logDebug:@"Client is already running."];
    }
    
    return startedSucessfuly;
}

-(BOOL)stop {
    BOOL stoppedSucessfuly = NO;
    
    if (_isStarted) {
        [self flushBuffer:YES];
        _isStarted = NO;
        stoppedSucessfuly = YES;
        [_logger logDebug:@"Client was stopped."];
    } else {
        [_logger logDebug:@"Client is not started."];
    }
    
    return stoppedSucessfuly;
}

#pragma mark - Public Methods

-(void)counterWithName:(NSString*)name value:(NSNumber*)value {
    [self counterWithName:name value:value options:nil];
}

-(void)counterWithName:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options {
    [self methodWithType:@"counter" name:name value:value options:options];
}

-(void)gaugeWithName:(NSString*)name value:(NSNumber*)value {
    [self gaugeWithName:name value:value options:nil];
}

-(void)gaugeWithName:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options {
    [self methodWithType:@"gauge" name:name value:value options:options];
}

-(void)timerWithName:(NSString*)name value:(NSNumber*)value {
    [self timerWithName:name value:value options:nil];
}

-(void)timerWithName:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options {
    [self methodWithType:@"timer" name:name value:value options:options];
}

-(void)methodWithType:(NSString*)type name:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options {
    NSDictionary *processedOptions = [self calculateConfigForType:type withOptions:options];
    [self putWithType:type name:name value:value options:processedOptions];
}

-(NSString*)metricBuilderWithType:(NSString*)type name:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options {
    NSMutableString *tags = [[NSMutableString alloc] init];
    NSMutableString *aggs = [[NSMutableString alloc] init];
    NSString* aggsWithAggFreq = @"";
    NSDictionary *tags_in_dict = options[@"tags"];
    NSDictionary *aggs_in_dict = options[@"agg"];
    
    for (NSString* key in tags_in_dict) {
        NSString* value = [tags_in_dict objectForKey:key];
        [tags appendString:[NSString stringWithFormat:@",%@=%@",key,value]];
    }
    
    for (NSString* key in aggs_in_dict) {
        NSString* value = [aggs_in_dict objectForKey:key];
        [aggs appendString:[NSString stringWithFormat:@"%@=%@,",key,value]];
    }
    
    if (aggs.length > 0) {
        aggsWithAggFreq = [NSString stringWithFormat:@" %@%@", aggs, options[@"agg_freq"]];
    }
    
    NSString *metric = [NSString stringWithFormat:@"%@.%@.%@%@ %@ %lu%@", options[@"namespace"], type, name, tags, value, [options[@"timestamp"] integerValue], aggsWithAggFreq];
    
    return metric;
}

-(void)putRawWithType:(NSString*)type name:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options {
    NSString* metric = [self metricBuilderWithType:type name:name value:value options:options];
    [self.metricsBuffer addObject:metric];
    [self flushBuffer:NO];
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
            if (defaults[method][@"agg"]) {
                _defaults[method][@"agg"] = defaults[method][@"agg"];
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
    
    _isConfigCorrect = YES;
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

-(void)flushBuffer:(BOOL)force {
    if (self.metricsBuffer.count >= self.flushSize.intValue || force) {
        NSString *metricsToFlush = [self.metricsBuffer componentsJoinedByString:@"\n"];
        [self flushMetrics:metricsToFlush];
        [self.metricsBuffer removeAllObjects];
    }
}

-(void)flushBufferWithTimer {
    [self flushBuffer:YES];
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

-(NSDictionary*) calculateConfigForType:(NSString*) type {
    return [self calculateConfigForType:type withOptions:nil];
}

-(NSDictionary*) calculateConfigForType:(NSString*) type withOptions:(NSDictionary*) methodOptions {
    NSMutableDictionary* configOptions = [[NSMutableDictionary alloc]init];
    NSMutableDictionary* methodGlobalDefaults = _defaults[type];
    
    //Apply Global Tags and App tag if app was defined on client constructor
    configOptions[@"tags"] = _tags;
    if ([_app length] > 0) {
        [configOptions[@"tags"] addEntriesFromDictionary:@{@"app": _app}];
    }
    
    configOptions[@"namespace"] = _namespace;
    configOptions[@"timestamp"] = CURRENT_TIMESTAMP;
    
    // Calculate Defaults
    if ([methodGlobalDefaults objectForKey:@"tags"]) {
        [configOptions[@"tags"] addEntriesFromDictionary:methodGlobalDefaults[@"tags"]];
    } else {
        configOptions[@"tags"] = kDefaultTagsByMethod[type];
    }
    
    if ([methodGlobalDefaults objectForKey:@"agg"]) {
        configOptions[@"agg"] = methodGlobalDefaults[@"agg"];
    } else {
        configOptions[@"agg"] = kDefaultAggByMethod[type];
    }
    
    if ([methodGlobalDefaults objectForKey:@"agg_freq"]) {
        configOptions[@"agg_freq"] = methodGlobalDefaults[@"agg_freq"];
    } else {
        configOptions[@"agg_freq"] = kDefaultAggFreq;
    }
    
    // Merge with methodOptions if exists
    if (methodOptions != nil) {
        if ([methodOptions objectForKey:@"tags"]) {
            [configOptions[@"tags"] addEntriesFromDictionary:methodOptions[@"tags"]];
        }
        
        if ([methodOptions objectForKey:@"agg"]) {
            configOptions[@"agg"] = [self mergeArraysWithoutDuplicates:methodOptions[@"agg"] otherArray:configOptions[@"agg"]];
        }
        
        if ([methodOptions objectForKey:@"agg_freq"]) {
            configOptions[@"agg_freq"] = methodOptions[@"agg_freq"];
        }
        
        if ([methodOptions objectForKey:@"namespace"]) {
            configOptions[@"namespace"] = methodOptions[@"namespace"];
        }
        
        if ([methodOptions objectForKey:@"timestamp"]) {
            configOptions[@"timestamp"] = methodOptions[@"timestamp"];
        }
    }
    
    
    return configOptions;
}

-(NSArray*)mergeArraysWithoutDuplicates:(NSArray*)arrA otherArray:(NSArray*)arrB {
    NSMutableSet *set = [[NSMutableSet alloc] init];
    [set addObjectsFromArray:arrA];
    [set addObjectsFromArray:arrB];
    
    return [[set allObjects] mutableCopy];
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
             @"tags": @{@"required":@NO, @"default":kDefaultGlobalTags},
             @"sample_rate": @{@"required":@NO, @"default":kDefaultSampleRate},
             @"namespace": @{@"required":@NO, @"default":kDefaultNamespace},
             @"flush_size": @{@"required":@NO, @"default":kDefaultFlushSize},
             @"flush_interval": @{@"required":@NO, @"default":kDefaultFlushInterval},
             @"defaults": @{@"required":@NO, @"default":kDefaultDefaults}
    };
}

@end
