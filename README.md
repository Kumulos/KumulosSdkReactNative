# Kumulos React Native SDK [![npm version](https://badge.fury.io/js/kumulos-react-native.svg)](https://www.npmjs.com/package/kumulos-react-native)

Kumulos provides tools to build and host backend storage for apps, send push notifications, view audience and behavior analytics, and report on adoption, engagement and performance.

## Get Started

```
npm install kumulos-react-native --save
pod install --project-directory=ios
```

### Android Linking Steps (required)

You must add the following to your `android/app/build.gradle` file:

```
android {
    // ...

    packagingOptions {
        exclude 'META-INF/NOTICE'
        exclude 'META-INF/ASL2.0'
        exclude 'META-INF/LICENSE'
    }
}
```

### SDK Initialization

After installation & linking, you can now initialize the SDK with:

In your `App.js`:

```javascript
import Kumulos from 'kumulos-react-native';

Kumulos.initialize({
    apiKey: 'YOUR_API_KEY',
    secretKey: 'YOUR_SECRET_KEY',
});
```

In your `ios/AppDelegate.m` `application:didFinishLaunchingWithOptions:` method:

```objective-c
#import <KumulosReactNative/KumulosReactNative.h>
...
KSConfig* kumulosConfig = [KSConfig
                             configWithAPIKey:@"YOUR_API_KEY"
                             andSecretKey:@"YOUR_SECRET_KEY"];

[KumulosReactNative initializeWithConfig:kumulosConfig];
```

In your `android/app/src/main/java/.../MainApplication.java` `onCreate` method:

```java
import com.kumulos.android.KumulosConfig;
import com.kumulos.reactnative.KumulosReactNative;
...
KumulosConfig.Builder kumulosConfig = new KumulosConfig.Builder("YOUR_API_KEY", "YOUR_SECRET_KEY");
KumulosReactNative.initialize(this, kumulosConfig);
```

For more information on integrating the React Native SDK with your project, please see the [Kumulos React Native integration guide](https://docs.kumulos.com/integration/react-native).

## Contributing

Pull requests are welcome for any improvements you might wish to make. If it's something big and you're not sure about it yet, we'd be happy to discuss it first. You can either file an issue or drop us a line to [support@kumulos.com](mailto:support@kumulos.com).

## License

This project is licensed under the MIT license with portions licensed under the BSD 2-Clause license. See our LICENSE file and individual source files for more information.

## React Native Version Support

| RN Version        | SDK Version             | Docs                                                                           |
| ----------------- | ----------------------- | ------------------------------------------------------------------------------ |
| >= 0.60           | 8.x, 7.x, 6.x, 5.x, 4.x | [Docs](https://github.com/Kumulos/KumulosSdkReactNative/blob/master/README.md) |
| >= 0.59 && < 0.60 | 3.0.0                   | [Docs](https://github.com/Kumulos/KumulosSdkReactNative/blob/3.0.0/README.md)  |
| >= 0.46 && < 0.59 | 2.1.0                   | [Docs](https://github.com/Kumulos/KumulosSdkReactNative/blob/2.1.0/README.md)  |
