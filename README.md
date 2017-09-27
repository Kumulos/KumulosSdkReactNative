# Kumulos React Native SDK [![npm version](https://badge.fury.io/js/kumulos-react-native.svg)](https://www.npmjs.com/package/kumulos-react-native)

Kumulos provides tools to build and host backend storage for apps, send push notifications, view audience and behavior analytics, and report on adoption, engagement and performance.

## Get Started

```
npm install kumulos-react-native --save
react-native link kumulos-react-native
react-native link react-native-device-info
```

After installation & linking, you can now initialize the SDK with:

```javascript
import KumulosClient from 'kumulos-react-native';

const client = new KumulosClient({
    apiKey: "YOUR_API_KEY",
    secretKey: "YOUR_SECRET_KEY"
});
```

For more information on integrating the React Native SDK with your project, please see the [Kumulos React Native integration guide](https://docs.kumulos.com/integration/react-native).

## Contributing

Pull requests are welcome for any improvements you might wish to make. If it's something big and you're not sure about it yet, we'd be happy to discuss it first. You can either file an issue or drop us a line to [support@kumulos.com](mailto:support@kumulos.com).

## License

This project is licensed under the MIT license with portions licensed under the BSD 2-Clause license. See our LICENSE file and individual source files for more information.
