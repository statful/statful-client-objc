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
#import "SFConstants.h"

@interface SFCommunicationHTTP ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) NSOperationQueue *operationsQueue;
@property (nonatomic, strong) NSURL *requestURL;

@end

@implementation SFCommunicationHTTP

#pragma mark - SFCommunicationProtocol Methods

- (instancetype)initWithDictionary:(NSDictionary *)dictionary completionBlock:(SFCommunicationCompletionBlock)completionBlock {
    
    if (self = [super init]) {
        
        _operationsQueue = [[NSOperationQueue alloc] init];
        _operationsQueue.name = NSStringFromClass([self class]);
        
        _requestURL = ({
            BOOL secure = [dictionary[@"secure"] boolValue];
            NSString *host = dictionary[@"host"];
            NSString *port = dictionary[@"port"];

            NSURL *url;
            
            if (secure) {
                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@:%@%@", @"https://", host, port, kApiPath]];
            } else {
                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@:%@%@", @"http://", host, port, kApiPath]];
            }
            
            url;
        });
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.securityPolicy.allowInvalidCertificates = YES;
        manager.operationQueue = self.operationsQueue;
        
        AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
        [requestSerializer setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
        [requestSerializer setValue:dictionary[@"token"] forHTTPHeaderField:@"M-Api-Token"];
        [requestSerializer setValue:@"text/plain; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [requestSerializer setValue:@"text/plain; charset=utf-8" forHTTPHeaderField:@"Accept"];
        requestSerializer.timeoutInterval = ([dictionary[@"timeout"] doubleValue] /1000.0f);
        manager.requestSerializer = requestSerializer;
        
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        NSMutableSet *acceptableContentTypes = [responseSerializer.acceptableContentTypes mutableCopy];
        [acceptableContentTypes addObject:@"text/plain; charset=utf-8"];
        responseSerializer.acceptableContentTypes = acceptableContentTypes;
        manager.responseSerializer = responseSerializer;
        
        _manager = manager;
        
        completionBlock(YES, nil);
    }
    
    return self;
}

- (void)sendMetricsData:(id)metricsData completionBlock:(SFCommunicationCompletionBlock)completionBlock {
    NSError *error = nil;
    
    NSMutableURLRequest *request = [self.manager.requestSerializer requestWithMethod:@"PUT" URLString:[_requestURL absoluteString] parameters:nil error:&error];
    
    if (request) {
        
        NSMutableData *postBody = [NSMutableData data];
        [postBody appendData:metricsData];
        [request setHTTPBody:postBody];
    }
    
    AFHTTPRequestOperation *httpOperation = [self.manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        completionBlock(YES, error);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completionBlock(NO, error);
    }];
    
    [httpOperation start];
}

@end
