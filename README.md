# Kumulos React Native SDK [![npm version](https://badge.fury.io/js/kumulos-react-native.svg)](https://www.npmjs.com/package/kumulos-react-native)

Kumulos provides tools to build and host backend storage for apps, send push notifications, view audience and behavior analytics, and report on adoption, engagement and performance.

## Get Started

```
npm install kumulos-react-native --save
react-native link kumulos-react-native
```

### iOS Linking Steps (required)

To complete the linking process for iOS, it is necessary to manually link the data model file used by Kumulos for offline event persistence.

To link the data model:

1. Open the Xcode project for your react native app
2. Locate the linked `kumulos` library project
3. Drag the `KAnalyticsModel.xcdatamodel` file from the `kumulos` project to the root of your app project

### Android Linking Steps (required)

To complete the linking process for Android, you need to ensure your project uses the following versions for tools & libraries:

- Gradle plugin v3.1.3 or greater
- Build tools v23.0.3 or greater
- Support library v27.+

In addition, you must add the following to your `android/app/build.gradle` file:

```
android {
    ...

    defaultConfig {
        ...

        manifestPlaceholders = [
                kumulos_gcm_sender_id: ''
        ]
    }

    packagingOptions {
        exclude 'META-INF/NOTICE'
        exclude 'META-INF/ASL2.0'
        exclude 'META-INF/LICENSE'
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```

### SDK Initialization

After installation & linking, you can now initialize the SDK with:

```javascript
import Kumulos from 'kumulos-react-native';

Kumulos.initialize({
    apiKey: 'YOUR_API_KEY',
    secretKey: 'YOUR_SECRET_KEY'
});
```

For more information on integrating the React Native SDK with your project, please see the [Kumulos React Native integration guide](https://docs.kumulos.com/integration/react-native).

## Contributing

Pull requests are welcome for any improvements you might wish to make. If it's something big and you're not sure about it yet, we'd be happy to discuss it first. You can either file an issue or drop us a line to [support@kumulos.com](mailto:support@kumulos.com).

## License

This project is licensed under the MIT license with portions licensed under the BSD 2-Clause license. See our LICENSE file and individual source files for more information.
