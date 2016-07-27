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
// - Public Documentation
// - Add some unit tests with stub dependencies methods
// - Configure the project for carthage too
// - Later on add some system stats automatically

#import "SFClient.h"
#import "SFClient+Private.h"
#import "SFConstants.h"

@implementation SFClient

#pragma mark - Convenience Initialisers

+ (instancetype)clientWithConfig:(NSDictionary *)config {
    
    return [[[self class] alloc] initWithConfig:config];
}

- (instancetype)initWithConfig:(NSDictionary *)config {
    
    if (self = [super init]) {
        _isStarted = NO;
        _isConfigValid = NO;
        _metricsBuffer = [[NSMutableArray alloc] init];
        
        @try {
            [self validateAndSetConfig:config];
        }
        @catch(NSException* e) {
            _isStarted = NO;
            _isConfigValid = NO;
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
        @throw [NSException exceptionWithName:@"SFClientTransportInitError" reason:[NSString stringWithFormat:@"Error initing transport layer: %@.", errorInit] userInfo:nil];
    }
}

-(void)initFlushTimer {
    self.flushTimer = [NSTimer scheduledTimerWithTimeInterval:([self.flushInterval floatValue]/1000.0f) target:self selector:@selector(flushBufferWithTimer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_flushTimer forMode:NSDefaultRunLoopMode];
}

-(BOOL)start {
    BOOL startedSucessfuly = NO;
    
    if (!_isStarted) {
        if (_isConfigValid) {
            @try {
                // Clear buffer to start
                [self.metricsBuffer removeAllObjects];
                
                // Init the transport layer and the flush rate timer
                [self initTransportLayer];
                [self initFlushTimer];
            
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
        [self.flushTimer invalidate];
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
    if ([self areMethodOptionsValid:options]) {
        if ([kImplementedMethods containsObject:type]) {
            NSDictionary *processedOptions = [self calculateConfigForType:type withOptions:options];
            [self putWithType:type name:name value:value options:processedOptions];
        } else {
            [_logger logError:@"Metric not sent. Method type is not supported."];
        }
    } else {
        [_logger logError:@"Metric not sent. Please review the following: aggregations, aggregation frequency and tags."];
    }
}

-(BOOL)areMethodOptionsValid:(NSDictionary*)options {
    BOOL isValid = YES;
    
    if ([options objectForKey:@"tags"] && isValid) {
        if (![self isTagsValid:options[@"tags"]]) {
            isValid = NO;
        }
    }
    
    if ([options objectForKey:@"agg"] && isValid) {
        if (![self isAggValid:options[@"agg"]]) {
            isValid = NO;
        }
    }
    
    if ([options objectForKey:@"agg_freq"] && isValid) {
        if (![self isAggFreqValid:options[@"agg_freq"]]) {
            isValid = NO;
        }
    }
    
    if ([options objectForKey:@"namespace"] && isValid) {
        if (![self isNamespaceValid:options[@"namespace"]]) {
            isValid = NO;
        }
    }
    
    if ([options objectForKey:@"timestamp"] && isValid) {
        if (![self isTimestampValid:options[@"timestamp"]]) {
            isValid = NO;
        }
    }
    
    return isValid;
}

-(NSString*)metricBuilderWithType:(NSString*)type name:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options {
    NSMutableString *tags = [[NSMutableString alloc] init];
    NSMutableString *aggs = [[NSMutableString alloc] init];
    NSString* aggsWithAggFreq = @"";
    NSDictionary *tags_in_dict = options[@"tags"];
    NSArray *aggs_in_array = options[@"agg"];
    
    for (NSString* key in tags_in_dict) {
        NSString* value = [tags_in_dict objectForKey:key];
        [tags appendString:[NSString stringWithFormat:@",%@=%@",key,value]];
    }
    
    for (NSString* agg in aggs_in_array) {
        [aggs appendString:[NSString stringWithFormat:@"%@,",agg]];
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

- (void)setDefaults:(id)defaults {
    if (![defaults isKindOfClass:[NSDictionary class]]) {
        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:@"Error setting defaults: should be a NSDictionary." userInfo:nil];
    } else {
        _defaults = [[NSMutableDictionary alloc]initWithCapacity:[defaults count]];
        
        for (NSString* method in kImplementedMethods) {
            if (defaults[method]) {
                _defaults[method] = [[NSMutableDictionary alloc] init];
                
                if ([defaults[method] objectForKey:@"tags"]) {
                    if ([self isTagsValid:defaults[method][@"tags"]]) {
                        _defaults[method][@"tags"] = defaults[method][@"tags"];
                    } else {
                        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:[NSString stringWithFormat:@"Error setting defaults.tags on method %@", method] userInfo:nil];
                    }
                }
                if ([defaults[method] objectForKey:@"agg"]) {
                    if ([self isAggValid:defaults[method][@"agg"]]) {
                        _defaults[method][@"agg"] = defaults[method][@"agg"];
                    } else {
                        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:[NSString stringWithFormat:@"Error setting defaults.agg on method %@", method] userInfo:nil];
                    }
                }
                if ([defaults[method] objectForKey:@"agg_freq"]) {
                    if ([self isAggFreqValid:defaults[method][@"agg_freq"]]) {
                        _defaults[method][@"agg_freq"] = defaults[method][@"agg_freq"];
                    } else {
                        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:[NSString stringWithFormat:@"Error setting defaults.aggFreq on method %@", method] userInfo:nil];
                    }
                }
            }
        }
    }
}

- (void)setSampleRate:(id)sampleRate {
    if (![sampleRate isKindOfClass:[NSNumber class]]) {
        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:@"Error setting sample rate: should be a NSNumber." userInfo:nil];
    } else if ([sampleRate intValue] <= 0 || [sampleRate intValue] >= 101) {
        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:@"Error setting sample rate: should be in rage [1, 100]." userInfo:nil];
    } else {
       _sampleRate = sampleRate;
    }
}

-(void)setTransport:(SFClientTransport)transport {
    if (transport == SFClientTransportUDP || transport == SFClientTransportAPI) {
        _transport = transport;
    } else {
        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:@"Error setting transport: should be SFClientTransportUDP or SFClientTransportAPI." userInfo:nil];
    }
}

-(void)setTags:(id)tags {
    if ([self isTagsValid:tags]) {
        _tags = tags;
    } else {
        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:@"Error setting tags: should be a NSDictionary." userInfo:nil];
    }
}

-(void)setHost:(id)host {
    if ([host isKindOfClass:[NSString class]]) {
        _host = host;
    } else {
        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:@"Error setting host: should be a NSString." userInfo:nil];
    }
}

-(void)setPort:(id)port {
    if ([port isKindOfClass:[NSString class]]) {
        _port = port;
    } else {
        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:@"Error setting port: should be a NSString." userInfo:nil];
    }
}

-(void)setSecure:(id)secure {
    if ([secure isKindOfClass:[NSNumber class]]) {
        _secure = secure;
    } else {
        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:@"Error setting secure: should be a NSNumber (0 or 1)." userInfo:nil];
    }
}

-(void)setTimeout:(id)timeout {
    if ([timeout isKindOfClass:[NSNumber class]]) {
        _timeout = timeout;
    } else {
        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:@"Error setting timeout: should be a NSNumber (unit is ms)." userInfo:nil];
    }
}

-(void)setToken:(id)token {
    if ([token isKindOfClass:[NSString class]]) {
        _token = token;
    } else {
        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:@"Error setting token: should be a NSString." userInfo:nil];
    }
}

-(void)setApp:(id)app {
    if ([app isKindOfClass:[NSString class]]) {
        _app = app;
    } else {
        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:@"Error setting app: should be a NSString." userInfo:nil];
    }
}

-(void)setDryrun:(id)dryrun {
    if ([dryrun isKindOfClass:[NSNumber class]]) {
        _dryrun = dryrun;
    } else {
        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:@"Error setting dryrun: should be a NSNumber (0 or 1)." userInfo:nil];
    }
}

-(void)setNamespace:(id)namespace {
    if ([namespace isKindOfClass:[NSString class]]) {
        _namespace = namespace;
    } else {
        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:@"Error setting namespace: should be a NSString." userInfo:nil];
    }
}

-(void)setFlushSize:(id)flushSize {
    if ([flushSize isKindOfClass:[NSNumber class]] && [flushSize isGreaterThan:@0]) {
        _flushSize = flushSize;
    } else {
        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:@"Error setting flush size: should be a NSNumber." userInfo:nil];
    }
}

-(void)setFlushInterval:(id)flushInterval {
    if ([flushInterval isKindOfClass:[NSNumber class]] && [flushInterval isGreaterThan:@0]) {
        _flushInterval = flushInterval;
    } else {
        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:@"Error setting flush interval: should be a NSNumber greater than 0 (time unit is ms)." userInfo:nil];
    }
}

-(void)setLogger:(id)logger {
    if ([logger isKindOfClass:[DDAbstractLogger class]] || logger == nil) {
        _logger = [[SFLogger alloc] initWithDDLoggerInstance:logger loggerLevel:-1];
    } else {
        @throw [NSException exceptionWithName:@"SFClientConfigError" reason:@"Error setting logger: should be an instance of a custom implementation of DDAbstractLogger<DDLogger> or a default implementation like: [DDTTYLogger sharedInstance] or [DDASLLogger sharedInstance]. Read CocoaLumberjack documentation to get more information." userInfo:nil];
    }
}

-(void)validateAndSetConfig:(NSDictionary *)config {
    __block SFClient *blocksafeSelf = self;
    NSDictionary* propertiesRules = getPropertiesRules();
    
    // Logger
    [self setProperty:@"logger" fromConfig:config WithRules:propertiesRules[@"logger"] AndWithSetter:^(id value) {
        [blocksafeSelf setLogger:value];
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
    
    _isConfigValid = YES;
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
    if (self.metricsBuffer.count >= self.flushSize.intValue || (force && self.metricsBuffer.count > 0)) {
        NSString *metricsToFlush = [self.metricsBuffer componentsJoinedByString:@"\n"];
        [self flushMetrics:metricsToFlush];
        [self.metricsBuffer removeAllObjects];
    }
}

-(void)flushBufferWithTimer {
    [self flushBuffer:YES];
}

-(void)flushMetrics:(NSString*)metrics {
    if (_isStarted) {
        if ([self.dryrun isEqualTo:@YES]) {
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
    } else {
        [_logger logError:@"Can't flush metrics while client is not started."];
    }
}

-(NSDictionary*) calculateConfigForType:(NSString*) type {
    return [self calculateConfigForType:type withOptions:nil];
}

-(NSDictionary*) calculateConfigForType:(NSString*) type withOptions:(NSDictionary*) methodOptions {
    NSMutableDictionary* configOptions = [[NSMutableDictionary alloc]init];
    NSMutableDictionary* methodGlobalDefaults = _defaults[type];
    
    //Apply Global Tags and App tag if app was defined on client constructor
    configOptions[@"tags"] = [NSMutableDictionary dictionaryWithDictionary:_tags];
    if ([_app length] > 0) {
        [configOptions[@"tags"] addEntriesFromDictionary:@{@"app": _app}];
    }
    
    configOptions[@"namespace"] = _namespace;
    configOptions[@"timestamp"] = CURRENT_TIMESTAMP;
    
    // Calculate Defaults
    if ([methodGlobalDefaults objectForKey:@"tags"]) {
        [configOptions[@"tags"] addEntriesFromDictionary:methodGlobalDefaults[@"tags"]];
    } else {
        [configOptions[@"tags"] addEntriesFromDictionary:kDefaultTagsByMethod[type]];
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

-(BOOL)isTagsValid:(id) tags {
    return [tags isKindOfClass:[NSDictionary class]];
}

-(BOOL)isAggFreqValid:(id) aggFreq {
    return [aggFreq isKindOfClass:[NSNumber class]] && [kSupportedAggFreq containsObject:aggFreq];
}

-(BOOL)isAggValid:(id) aggs {
    BOOL isValid = YES;
    
    if ([aggs isKindOfClass:[NSArray class]]) {
        for (NSString* agg in aggs) {
            if (![kSupportedAgg containsObject:agg]) {
                isValid = NO;
                break;
            }
        }
    } else {
        isValid = NO;
    }
    
    return isValid;
}

-(BOOL)isNamespaceValid:(id) namespace {
    return [namespace isKindOfClass:[NSString class]];
}

-(BOOL)isTimestampValid:(id) timestamp {
    return [timestamp isKindOfClass:[NSString class]];
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
