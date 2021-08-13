### Description of Changes

(briefly outline the reason for changes, and describe what's been done)

### Breaking Changes

-   None

### Release Checklist

Prepare:

-   [ ] Detail any breaking changes. Breaking changes require a new major version number
-   [ ] Check `pod lib lint` passes

Bump versions in:

-   [ ] `package.json`
-   [ ] `src/ios/KumulosReactNative.m`
-   [ ] `src/android/.../KumulosReactNative.java`
-   [ ] `README.md`

Release:

-   [ ] Squash and merge to master
-   [ ] Delete branch once merged
-   [ ] Create tag from master matching chosen version
-   [ ] Run `npm publish` to push to NPM

Update changelog:

- [ ] https://docs.kumulos.com/developer-guide/sdk-reference/react-native/#changelog

