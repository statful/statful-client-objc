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
#import "SFLogger.h"

@interface SFClient : NSObject

#pragma mark - Properties
@property (strong, nonatomic) SFLogger *logger;
@property (assign, nonatomic) BOOL isStarted;
@property (assign, nonatomic) BOOL isConfigValid;

#pragma mark - Convenience Initialisers
+ (instancetype)clientWithConfig:(NSDictionary*)config;
- (instancetype)initWithConfig:(NSDictionary*)config NS_DESIGNATED_INITIALIZER;
- (BOOL)start;
- (BOOL)stop;

#pragma mark - Public Methods
/**
 *  Sends a counter metric wihtout options
 *
 *  @param name    Name of the counter. Ex: transactions
 *  @param value   Value of the counter. Ex: @1
 */
-(void)counterWithName:(NSString*)name value:(NSNumber*)value;

/**
 *  Sends a counter metric
 *
 *  @param name    Name of the counter. Ex: transactions
 *  @param value   Value of the counter. Ex: @1
 *  @param options A NSDictionary with metric options: tags, agg, aggFreq, namespace and timestamp
 *          - tags: Tags to associate this value with, for example @{@"from": @"serviceA", @"to": @"serviceB",
 *            @"method": @"login"}
 *          - agg: NSArray of aggregations to be applied by the client. Ex: @[@"avg", @"p90", @"min"]
 *          - aggFreq: Aggregation frequency in seconds. One of: @10, @15, @30, @60, @120, @180 or @300
 *          - namespace: Define the metric namespace. Default: application
 *          - timestamp: Define the metric timestamp (unit is seconds). Default: current timestamp
 */
-(void)counterWithName:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options;

/**
 *  Sends a gauge metric wihtout options
 *
 *  @param name    Name of the gauge. Ex: current_sessions
 *  @param value   Value of the gauge. Ex: @1
 */
-(void)gaugeWithName:(NSString*)name value:(NSNumber*)value;

/**
 *  Sends a gauge metric
 *
 *  @param name    Name of the gauge. Ex: current_sessions
 *  @param value   Value of the gauge. Ex: @1
 *  @param options A NSDictionary with metric options: tags, agg, aggFreq, namespace and timestamp
 *          - tags: Tags to associate this value with, for example @{@"from": @"serviceA", @"to": @"serviceB",
 *            @"method": @"login"}
 *          - agg: NSArray of aggregations to be applied by the client. Ex: @[@"avg", @"p90", @"min"]
 *          - aggFreq: Aggregation frequency in seconds. One of: @10, @15, @30, @60, @120, @180 or @300
 *          - namespace: Define the metric namespace. Default: application
 *          - timestamp: Define the metric timestamp (unit is seconds). Default: current timestamp
 */
-(void)gaugeWithName:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options;

/**
 *  Sends a timing metric wihtout options
 *
 *  @param name    Name of the timer. Ex: response_time
 *  @param value   Value of the timer. Ex: @1
 */
-(void)timerWithName:(NSString*)name value:(NSNumber*)value;

/**
 *  Sends a timing metric
 *
 *  @param name    Name of the timer. Ex: response_time
 *  @param value   Value of the timer. Ex: @1
 *  @param options A NSDictionary with metric options: tags, agg, aggFreq, namespace and timestamp
 *          - tags: Tags to associate this value with, for example @{@"from": @"serviceA", @"to": @"serviceB", 
 *            @"method": @"login"}
 *          - agg: NSArray of aggregations to be applied by the client. Ex: @[@"avg", @"p90", @"min"]
 *          - aggFreq: Aggregation frequency in seconds. One of: @10, @15, @30, @60, @120, @180 or @300
 *          - namespace: Define the metric namespace. Default: application
 *          - timestamp: Define the metric timestamp (unit is seconds). Default: current timestamp
 */
-(void)timerWithName:(NSString*)name value:(NSNumber*)value options:(NSDictionary*)options;

@end
