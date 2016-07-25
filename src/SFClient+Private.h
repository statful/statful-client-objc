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

#import "SFClient.h"

@interface SFClient ()

// Implementation related properties
@property (strong, nonatomic) NSMutableArray *metricsBuffer;
@property (strong, nonatomic) NSString *app;
@property (strong, nonatomic) NSNumber *dryrun;
@property (strong, nonatomic) NSNumber *flushSize;
@property (strong, nonatomic) NSNumber *flushInterval;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSString *port;
@property (strong, nonatomic) NSNumber *sampleRate;
@property (strong, nonatomic) NSNumber *secure;
@property (strong, nonatomic) NSDictionary  *tags;
@property (strong, nonatomic) NSNumber *timeout;
@property (strong, nonatomic) NSString *token;
@property (assign, nonatomic) SFClientTransport transport;
@property (strong, nonatomic) NSString *namespace;
@property (strong, nonatomic) NSMutableDictionary *defaults;
@property (strong, nonatomic) NSTimer *flushTimer;

@end
