# Analytics-Swift Appcues
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/appcues/segment-appcues-ios/blob/main/LICENSE)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fappcues%2Fsegment-appcues-ios%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/appcues/segment-appcues-ios)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fappcues%2Fsegment-appcues-ios%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/appcues/segment-appcues-ios)

Add Appcues device mode support to your applications via this plugin for [Analytics-Swift](https://github.com/segmentio/analytics-swift)

## Adding the dependency

**Note:** the Appcues library itself will be installed as an additional dependency. An installation [tutorial video](https://appcues.wistia.com/medias/2m0v84kv0e) is also available, for reference.

### via Xcode
In the Xcode `File` menu, click `Add Packages`. You'll see a dialog where you can search for Swift packages. In the search field, enter the URL to this repo.

https://github.com/appcues/segment-appcues-ios

You'll then have the option to pin to a version, or specific branch, as well as which project in your workspace to add it to. Once you've made your selections, click the `Add Package` button.

### via Package.swift

Open your Package.swift file and add the following do your the `dependencies` section:

```
.package(
        url: "https://github.com/appcues/segment-appcues-ios.git",
        from: "5.0.0"
    ),
```

## Using the Plugin in your App

Open the file where you setup and configure the Analytics-Swift library.  Add this plugin to the list of imports.

```
import Segment
import SegmentAppcues // <-- Add this line
```

Just under your Analytics-Swift library setup, call `analytics.add(plugin: ...)` to add an instance of the plugin to the Analytics timeline.

```
let analytics = Analytics(configuration: Configuration(writeKey: "<YOUR WRITE KEY>")
    .flushAt(3)
    .trackApplicationLifecycleEvents(true))
analytics.add(plugin: AppcuesDestination())
```

Your events will now begin to flow to Appcues in device mode.

## Supporting Builder Preview and Screen Capture

During installation, follow the steps outlined in in the Appcues iOS SDK documentation for [Configuring the Appcues URL Scheme](https://appcues.github.io/appcues-ios-sdk/documentation/appcueskit/urlschemeconfiguring). This is necessary for the complete Appcues builder experience, supporting experience preview, screen capture and debugging.

## Support

Please use Github issues, Pull Requests, or feel free to reach out to our [support team](mailto:support@appcues.com).
