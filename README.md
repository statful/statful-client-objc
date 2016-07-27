# Statful Client Objective-C

Statful client for OS-X and iOS written in Objective-C.
This client is intended to gather metrics and send them to the Statful service.

Please check out our [website](http://statful.com) or our extended [documentation](http://statful.com/docs) for a comprehensive look at all features available on Statful.

## Supported Platforms

| StatfulClient Version | Minimum iOS Target  | Minimum macOS Target  | Minimum watchOS Target  | Minimum tvOS Target  |                                   Notes                                   |
|:--------------------:|:---------------------------:|:----------------------------:|:----------------------------:|:----------------------------:|:-------------------------------------------------------------------------:|
| 1.0.x | iOS 6 | OS X 10.8 | n/a | n/a | Xcode 7+ is required |

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

## Quick Start ##
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
> **IMPORTANT** This configuration uses the default **host** and **port**. You can learn more about configuration in [Configurations](#configurations).

## API Reference ## 

### Client ###

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

#### Methods ####
#### Properties ####

### Logger ###
#### Methods ####
#### Properties ####

## Examples ##
You can find here some useful usage examples of the Statful Client. In the following examples is assumed you have already installed and included Statful Client in your project.

### UDP Configuration ###

```objc
NSDictionary *clientConfig = @{ @"transport":@(SFClientTransportUDP), 
                                @"host": @"statful-relay.yourcompany.com",
                                @"app": @"AccountService",
                                @"tags": @{@"cluster": @"production"}
                             };
SFClient *statfulClient = [SFClient clientWithConfig:clientConfig];
```

### HTTP Configuration ###

```objc
NSDictionary *clientConfig = @{ @"transport":@(SFClientTransportAPI), 
                                @"host": @"statful-relay.yourcompany.com",
                                @"token": @"YOUR_TOKEN_FOR_STATFUL_API",
                                @"app": @"AccountService",
                                @"tags": @{@"cluster": @"production"}
                             };
SFClient *statfulClient = [SFClient clientWithConfig:clientConfig];
```

### Logger Configuration ###
### Defaults Configuration Per Method ###
### Mixed Complete Configuration ###
### Add metrics ###

## Still need help? ##
If you are feeling that you're still needing help, please visit our oficial full [Statful Documentation](http://statful.com/docs) page.

## Authors

Tiago Costa(@misticini), tiago.ferreira@mindera.com

## License

Statful Obj-C Client is available under the MIT license. See the [LICENSE](https://raw.githubusercontent.com/statful/statful-client-objc/master/LICENSE) file for more info.
