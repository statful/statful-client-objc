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

typedef NS_ENUM(short, SFClientTransport) {
    SFClientTransportTCP = 0,
    SFClientTransportUDP,
    SFClientTransportAPI,
};

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

FOUNDATION_EXTERN NSString const* SFCLientDefaultNamespace;
FOUNDATION_EXTERN NSString const* SFClientAPI_Path;
FOUNDATION_EXTERN NSString const* SFClientUSER_AGENT;

@interface SFClient : NSObject

#pragma mark - Properties

// Config properties
@property (strong, nonatomic) NSString *app;
@property (strong, nonatomic) NSNumber *dryrun;
@property (strong, nonatomic) NSNumber *flushSize;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSString *port;
@property (strong, nonatomic) NSString *prefix;
@property (strong, nonatomic) NSNumber *sampleRate;
@property (strong, nonatomic) NSNumber *secure;
@property (strong, nonatomic) NSArray  *tags;
@property (strong, nonatomic) NSNumber *timeout;
@property (strong, nonatomic) NSString *token;
@property (assign, nonatomic) SFClientTransport transport;

#pragma mark - Convenience Initialisers

+ (instancetype)clientWithConfig:(NSDictionary*)config;

- (instancetype)initWithConfig:(NSDictionary*)config NS_DESIGNATED_INITIALIZER;

#pragma mark - Public Methods

// FIX: Does all this methods need to be public?
//-(void)initTransportLayer;

// TODO: Complete this methods descriptions
/**
 *  <#Description#>
 *
 *  @param name  <#name description#>
 *  @param value <#value description#>
 */
-(void)counterWithName:(NSString*)name value:(NSNumber*)value;
/**
 *  <#Description#>
 *
 *  @param name    <#name description#>
 *  @param value   <#value description#>
 *  @param options <#options description#>
 */
-(void)counterWithName:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options;

/**
 *  <#Description#>
 *
 *  @param name  <#name description#>
 *  @param value <#value description#>
 */
-(void)gaugeWithName:(NSString*)name value:(NSNumber*)value;
/**
 *  <#Description#>
 *
 *  @param name    <#name description#>
 *  @param value   <#value description#>
 *  @param options <#options description#>
 */
-(void)gaugeWithName:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options;

// FIX: Do we need this methods?
-(NSString*)metricBuilderWithType:(NSString*)type name:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options;
-(void)putRawWithType:(NSString*)type name:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options;
-(void)putWithType:(NSString*)type name:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options;

/**
 *  <#Description#>
 *
 *  @param name  <#name description#>
 *  @param value <#value description#>
 */
-(void)timerWithName:(NSString*)name value:(NSNumber*)value;
/**
 *  <#Description#>
 *
 *  @param name    <#name description#>
 *  @param value   <#value description#>
 *  @param options <#options description#>
 */
-(void)timerWithName:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options;

// TODO: I think this method should be public, but i think we should add a class method to validate the configs.
-(BOOL)validateAndSetConfig:(NSDictionary*)config;


@end
