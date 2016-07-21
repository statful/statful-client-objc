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

#pragma mark - Convenience Initialisers
+ (instancetype)clientWithConfig:(NSDictionary*)config;
- (instancetype)initWithConfig:(NSDictionary*)config NS_DESIGNATED_INITIALIZER;

#pragma mark - Public Methods
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

@end
