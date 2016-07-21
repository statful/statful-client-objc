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

#import "SFCommunicationHTTP.h"

#import <AFNetworking/AFHTTPRequestOperationManager.h>

NSString* SFClientAPI_Path = @"/tel/v2.0/metrics";
NSString* SFClientUSER_AGENT = @"statful-client-objc/0.0.1";

@interface SFCommunicationHTTP ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) NSOperationQueue *operationsQueue;

@end

@implementation SFCommunicationHTTP

#pragma mark - SFCommunicationProtocol Methods

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"Statful-Client" ofType:@"podspec"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    if (error)
        NSLog(@"Error reading file: %@", error.localizedDescription);
    
    // maybe for debugging...
    NSLog(@"contents: %@", fileContents);
    
    NSArray *listArray = [fileContents componentsSeparatedByString:@"\n"];
    NSLog(@"items = %lu", (unsigned long)[listArray count]);
    
    if (self = [super init]) {
        
        _operationsQueue = [[NSOperationQueue alloc] init];
        _operationsQueue.name = NSStringFromClass([self class]);
        
        NSURL *baseURL = ({
            BOOL secure = [dictionary[@"secure"] boolValue];
            NSString *host = dictionary[@"host"];
            NSURL *url;
            
            if (secure) {
                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"https://", host]];
            } else {
                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://", host]];
            }
            
            url;
        });
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        // TODO: Should we use it only in DEBUG?
        manager.securityPolicy.allowInvalidCertificates = YES;
        manager.operationQueue = self.operationsQueue;
        
        AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
        [requestSerializer setValue:SFClientUSER_AGENT forHTTPHeaderField:@"User-Agent"];
        [requestSerializer setValue:dictionary[@"token"] forHTTPHeaderField:@"M-Api-Token"];
        [requestSerializer setValue:@"application/text" forHTTPHeaderField:@"content-type"];
        requestSerializer.timeoutInterval = [dictionary[@"timeout"] doubleValue];
        manager.requestSerializer = requestSerializer;
        
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        NSMutableSet *acceptableContentTypes = [responseSerializer.acceptableContentTypes mutableCopy];
        [acceptableContentTypes addObject:@"application/text"];
        responseSerializer.acceptableContentTypes = acceptableContentTypes;
        manager.responseSerializer = responseSerializer;
        
        _manager = manager;
    }
    
    return self;
}

- (void)sendMetricsData:(id)metricsData completionBlock:(SFCommunicationCompletionBlock)completionBlock {
    NSError *error = nil;
    
    NSMutableURLRequest *request = [self.manager.requestSerializer requestWithMethod:@"PUT" URLString:SFClientAPI_Path parameters:nil error:&error];
    
    if (request) {
        
        NSMutableData *postBody = [NSMutableData data];
        [postBody appendData:metricsData];
        
        [request setHTTPBody:postBody];
    }
    
    [self.manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        // Do something with response
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        // Do something with response
        
    }];
}

@end
