# Kumulos Objective-C SDK

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 
[![CocoaPods](https://img.shields.io/cocoapods/v/KumulosSdkObjectiveC.svg)](https://cocoapods.org/pods/KumulosSdkObjectiveC)


Kumulos provides tools to build and host backend storage for apps, send push notifications, view audience and behavior analytics, and report on adoption, engagement and performance.

Select an installation method below to get started.

## Get Started with CocoaPods

Add the following line to your app's target in your `Podfile`:

```
pod 'KumulosSdkObjectiveC', '~> 1.6'
```

Run `pod install` to install your dependencies.

After installation, you can now import & initialize the SDK with:

```objective-c
#import <KumulosSDK/KumulosSDK.h>

KSConfig *config = [KSConfig configWithAPIKey:@"YOUR_API_KEY" andSecretKey:@"YOUR_SECRET_KEY"];
[Kumulos initializeWithConfig:config];
```

For more information on integrating the Objective-C SDK with your project, please see the [Kumulos Objective-C integration guide](https://docs.kumulos.com/integration/ios).

## Get Started with Carthage

Add the following line to your `Cartfile`:

```
github "Kumulos/KumulosSdkObjectiveC" ~> 1.6
```

Run `carthage update` to install your dependencies then follow the [Carthage integration steps](https://github.com/Carthage/Carthage#getting-started) to link the framework with your project.

Please also ensure you link your project against:

- SystemConfiguration.framework
- MessageUI.framework (for iOS projects)
- libc++
- libz

After installation, you can now import & initialize the SDK with:

```objective-c
#import <KumulosSDK/KumulosSDK.h>

KSConfig *config = [KSConfig configWithAPIKey:@"YOUR_API_KEY" andSecretKey:@"YOUR_SECRET_KEY"];
[Kumulos initializeWithConfig:config];
```

For more information on integrating the Objective-C SDK with your project, please see the [Kumulos Objective-C integration guide](https://docs.kumulos.com/integration/ios).

## Contributing

Pull requests are welcome for any improvements you might wish to make. If it's something big and you're not sure about it yet, we'd be happy to discuss it first. You can either file an issue or drop us a line to [support@kumulos.com](mailto:support@kumulos.com).

To get started with development, simply clone this repo, run a `carthage update` and open the workspace to kick things off.

## License

This project is licensed under the MIT license with portions licensed under the BSD 2-Clause license. See our LICENSE file and individual source files for more information.

## Requirements

- iOS8+
