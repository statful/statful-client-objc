# Statful Client Objective-C

Statful client for OS-X and iOS written in Objective-C.
This client is intended to gather metrics and send them to the Statful service.

Please check out our [website](http://statful.com) or our extended [documentation](http://statful.com/docs) for a comprehensive look at all features available on Statful.

## Supported Platforms

| StatfulClient Version | Minimum iOS Target  | Minimum macOS Target  | Minimum watchOS Target  | Minimum tvOS Target  |                                   Notes                                   |
|:--------------------:|:---------------------------:|:----------------------------:|:----------------------------:|:----------------------------:|:-------------------------------------------------------------------------:|
| 1.0.x | 6.0 | 10.8 | n/a | n/a | Xcode 7+ is required |

> **IMPORTANT**: Your project must support [64-bit with modern Cocoa runtime](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtVersionsPlatforms.html)).

## Installation
Currently Statful Client Objective-C can only be installed with CocoaPods.

### CocoaPods

To install it using [CocoaPods](http://cocoapods.org), a dependency manager for Objective-C, ensure you have CocoaPods installed and configured on your project. 
If don't have it installed or configured in your project please check out [CocoaPods Documentation](https://guides.cocoapods.org).

#### Podfile

To integrate Statful Client into your Xcode project using CocoaPods, add this line to your `Podfile`:

```ruby
pod 'StatfulClientObjc', '~> 1.0.0'
```

And then run the following command:

```bash
$ pod install
```

#### Including Statful Client
At this point you only need to include Statful Client into your project to start using it. 

```objc
#import "SFClient.h"
```

## Quick Start
After installing Statful Client you are ready to use it. The quickest way is to do the following:

```objc
#import "SFClient.h"

// Creates a NSDictionary with configuration and pass it to the client
NSDictionary *clientConfig = @{@"transport":@(SFClientTransportAPI), @"token": @"YOUR_TOKEN_FOR_STATFUL_API"};
SFClient *statfulClient = [SFClient clientWithConfig:clientConfig];

// Starts the client to begin buffering and send metrics
// Any metric sent before the client start is ignored
[statfulClient start];

// Send a metric
[statfulClient counterWithName:@"testCounter" value:@0];

// Stop the client before exit yout application to ensure you'll not loose metrics
// Every metric in the buffer is sent when client stop is called
[statfulClient stop];
```
> **IMPORTANT** This configuration uses the default **host** and **port**. You can learn more about configuration in [API Reference](#api-reference).

## API Reference 

### Client

* __host__ [optional] [default: '127.0.0.1']
* __port__ [optional] [default: 2013]
* __secure__ [optional] [default: true] - enable or disable https
* __timeout__ [optional] [default: 1000ms] - socket timeout for http/tcp transports
* __token__ [optional] - An authentication token to send to Statful
* __app__ [optional] - if specified set a tag â€˜app=fooâ€™
* __dryrun__ [optional] [default: false] - do not actually send metrics when flushing the buffer
* __tags__ [optional] - global list of tags to set
* __sampleRate__ [optional] [default: 100] [between: 1-100] - global rate sampling
* __namespace__ [optional] [default: â€˜applicationâ€™] - default namespace (can be overridden in function calls)
* __flushSize__ [optional] [default: 10] - defines the periodicity of buffer flushes
* __flushInterval__ [optional] [default: 0] - Defines an interval to flush the metrics

#### Methods
#### Properties

### Logger
#### Methods
#### Properties

## Examples
You can find here some useful usage examples of the Statful Client. In the following examples is assumed you have already installed and included Statful Client in your project.

### UDP Configuration

Creates a simple UDP configuration for the client.

```objc
NSDictionary *clientConfig = @{ @"app": @"AccountService",
                                @"host": @"statful-relay.yourcompany.com",
                                @"tags": @{
                                    @"cluster": @"production"
                                },
                                @"transport":@(SFClientTransportUDP)
                             };
SFClient *statfulClient = [SFClient clientWithConfig:clientConfig];
```

### HTTP Configuration

Creates a simple HTTP API configuration for the client.

```objc
NSDictionary *clientConfig = @{ @"app": @"AccountService",
                                @"host": @"statful-relay.yourcompany.com",
                                @"tags": @{
                                    @"cluster": @"production"
                                },
                                @"token": @"YOUR_TOKEN_FOR_STATFUL_API",
                                @"transport":@(SFClientTransportAPI)
                             };
SFClient *statfulClient = [SFClient clientWithConfig:clientConfig];
```

### Logger Configuration

Creates a simple client configuration and change some logger's definitions.

```objc
NSDictionary *clientConfig = @{ @"host": @"statful-relay.yourcompany.com",
                                @"logger": [DDTTYLogger sharedInstance],
                                @"token": @"YOUR_TOKEN_FOR_STATFUL_API",
                                @"transport":@(SFClientTransportAPI)
                             };
                             
SFClient *statfulClient = [SFClient clientWithConfig:clientConfig];
                             
// Logger was instantiated with DDTTYLogger, a default implementation of Xcode Console Logger already provided by CocoaLumberjack. 
// Also is always instantiated with lower available logger level: SFLoggerLogLevelError.
// However you're able to change logger
statfulClient.logger.loggerLevel = SFLoggerLogLevelDebug;
                             
// You can also change the logger used by the client.
// For doing that you have to provide a logger that inherits from DDAbstractLogger <DDLogger>
// For example: 
statfulClient.logger.logger = [DDTTYLogger sharedInstance];

// Or 
DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
fileLogger.rollingFrequency = 60 * 60 * 24;
fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
statfulClient.logger.logger = fileLogger

```

### Defaults Configuration Per Method

Creates a configuration for the client with custom default options per method.

```objc
NSDictionary *clientConfig = @{ @"app": @"AccountService",
                                @"defaults": @{
                                    @"counter": @{
                                        @"agg": @[@"avg"],
                                        @"agg_freq": @180
                                    },
                                    @"gauge": @{
                                        @"agg": @[@"first"],
                                        @"agg_freq": @180
                                    },
                                    @"timer": @{
                                        @tags: @{
                                            @"cluster": @"qa"
                                        },
                                        @"agg": @[@"count"],
                                        @"agg_freq": @180
                                    }
                                },
                                @"host": @"statful-relay.yourcompany.com",
                                @"tags": @{
                                    @"cluster": @"production"
                                },
                                @"token": @"YOUR_TOKEN_FOR_STATFUL_API",
                                @"transport":@(SFClientTransportAPI)
                             };
SFClient *statfulClient = [SFClient clientWithConfig:clientConfig];
```

### Mixed Complete Configuration

Creates a configuration defining a value for every available option.

```objc
NSDictionary *clientConfig = @{ @"app": @"AccountService",
                                @"defaults": @{
                                    @"timer": @{
                                        @tags: @{
                                            @"cluster": @"qa"
                                        },
                                        @"agg": @[@"count"],
                                        @"agg_freq": @180
                                    }
                                },
                                @"dryrun": @YES,
                                @"flush_interval": @5000,
                                @"flush_size": @50,
                                @"host": @"statful-relay.yourcompany.com",
                                @"logger": [DDTTYLogger sharedInstance],
                                @"namespace": @"application",
                                @"port": @"123",
                                @"sample_rate": @95,
                                @"secure": @NO,
                                @"tags": @{
                                    @"cluster": @"production"
                                },
                                @"timeout": @300,
                                @"token": @"YOUR_TOKEN_FOR_STATFUL_API",
                                @"transport": @(SFClientTransportAPI)
                             };
SFClient *statfulClient = [SFClient clientWithConfig:clientConfig];
```

### Add Metrics

Creates a simple client configuration and use it to send some metrics.

```objc
NSDictionary *clientConfig = @{ @"host": @"statful-relay.yourcompany.com",
                                @"token": @"YOUR_TOKEN_FOR_STATFUL_API",
                                @"transport":@(SFClientTransportAPI)
                             };
SFClient *statfulClient = [SFClient clientWithConfig:clientConfig];

// Ignored metric
[statfulClient gaugeWithName:@"testTimer" value:@0];

[statfulClient start];

// Send three different metrics (gauge, timer and a counter)
// Attention: calling method gaugeWithName:value is equal to 
// calling gaugeWithName:value:options with null options
[statfulClient gaugeWithName:@"testTimer" value:@0];
[statfulClient timerWithName:@"testTimer" value:@0 options:nil];
[statfulClient timerWithName:@"testTimer" value:@0 options:@{@"agg": @[@"first"],
                                                             @"agg_freq": @60
                                                            }];
                                                            
// Metric to be sent with more custom options like timestamp instead of current timestamp
[statfulClient timerWithName:@"testTimer" value:@0 options:@{@"tags": @{
                                                                @"cluster": @"sandbox"
                                                             },
                                                             @"agg": @[@"last"],
                                                             @"agg_freq": @60
                                                             @"namespace": @"sandbox"
                                                             @"timestamp": @"1469714440"
                                                            }];
                                                            
[statfulClient stop];

// Ignored metric
[statfulClient gaugeWithName:@"testTimer" value:@0];

```

## Still Need Help?
If you are feeling that you're still needing help, please visit our oficial full [Statful Documentation](http://statful.com/docs) page.

## Authors

[Tiago Costa](https://github.com/misticini), tiago.ferreira@mindera.com

## License

Statful Obj-C Client is available under the MIT license. See the [LICENSE](https://raw.githubusercontent.com/statful/statful-client-objc/master/LICENSE) file for more info.
