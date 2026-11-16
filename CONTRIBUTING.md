# Contributing

## Dependencies

None. The SDK uses only Foundation, plus UIKit for colors when it is available. Please keep it that way: apps that add the SDK should not get third-party libraries with it.

It is published both as a Swift package (`Package.swift`) and as a CocoaPod (`croboxSDK.podspec`).

## Running the tests

```sh
swift test
```

CI runs the same command on macOS for every pull request.

Some test suites call the live Crobox API: `PromotionTests`, `PromotionFailureTests` and `EventTests`. They need a network connection and take a few seconds. To run only the offline suites:

```sh
swift test --filter 'UserAgentTests|RequestParametersTests|PromotionResponseTests|ColorUtilTest'
```

The tests need macOS, because the network layer uses async `URLSession` APIs that are not available on Linux. Tests for UIKit colors run only on an iOS target, for example from Xcode.

## The sample app

`app/` is a sample shop that uses the SDK from this checkout:

```sh
cd app
pod install
open App.xcworkspace
```

## Releasing

Releases are made by the **Release** workflow (Actions → Release → Run workflow). Enter the new version, for example `1.0.34`. Tags have no `v` prefix.

The workflow:

1. Sets the version in `Sources/Crobox/common/Version.swift`. The podspec reads its version from that file, and the SDK sends it in its `User-Agent` header.
2. Builds the package and lints the pod.
3. Commits the version on top of `main` as "Release x.y.z", tags that commit and pushes the tag. Swift Package Manager and CocoaPods both install from the tag.
4. Creates the GitHub release, with notes generated from the merged pull requests.
5. Publishes the pod with `pod trunk push`.

Branch protection does not let the workflow push to `main`, so the release commit exists only on its tag, and `Version.swift` on `main` stays at `0.0.0-dev`. Don't change it by hand.

The workflow needs the `COCOAPODS_TRUNK_TOKEN` repository secret: the token of a CocoaPods trunk owner of `croboxSDK`. To get one, run `pod trunk register <email> '<name>'`, confirm the email, and copy the password for `trunk.cocoapods.org` from `~/.netrc`.
