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

#import "SFCommunicationSocketUDP.h"
#import "SFCommunicationSocket+Private.h"

#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

@interface SFCommunicationSocketUDP ()

@property (nonatomic, strong) GCDAsyncUdpSocket *socket;

@end

@implementation SFCommunicationSocketUDP

#pragma mark - SFCommunicationProtocol Methods

- (instancetype)initWithDictionary:(NSDictionary *)dictionary completionBlock:(SFCommunicationCompletionBlock)completionBlock {
    
    if (self = [super initWithDictionary:dictionary completionBlock:completionBlock]) {
        
        NSError *error = nil;
        _socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:self.queue];
        
        // Accordingly with documentation, connectToHost will return right away, so we don't need to provide an error. However, we should listen the delegate methods
        if(![_socket connectToHost:self.host onPort:self.port error:&error]) {
            completionBlock(NO, error);
        } else {
            completionBlock(YES, nil);
        }
    }
    
    return self;
}

- (void)sendMetricsData:(id)metricsData completionBlock:(SFCommunicationCompletionBlock)completionBlock {
    
    [self.socket sendData:metricsData withTimeout:self.timeout tag:0];
    completionBlock(YES, nil);
}

@end
