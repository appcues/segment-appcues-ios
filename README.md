# Analytics-Swift Appcues

>NOTE: This is a pre-release project for testing as a part of our mobile beta program. If you are interested in learning more about our mobile product and testing it before it is officially released, please [visit our site](https://www.appcues.com/mobile) and request early access.
>
>If you have been contacted to be a part of our mobile beta program, we encourage you to try out this library and provide feedback via Github issues and pull requests. Please note this library will not operate if you are not part of the mobile beta program.

Add Appcues device mode support to your applications via this plugin for [Analytics-Swift](https://github.com/segmentio/analytics-swift)

## Adding the dependency

**Note:** the Appcues library itself will be installed as an additional dependency.

### via Xcode
In the Xcode `File` menu, click `Add Packages`. You'll see a dialog where you can search for Swift packages. In the search field, enter the URL to this repo.

https://github.com/appcues/segment-appcues-ios

You'll then have the option to pin to a version, or specific branch, as well as which project in your workspace to add it to. Once you've made your selections, click the `Add Package` button.

### via Package.swift

Open your Package.swift file and add the following do your the `dependencies` section:

```
.package(
        name: "Segment",
        url: "https://github.com/appcues/segment-appcues-ios.git",
        from: "1.0.0"
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

## Support

Please use Github issues, Pull Requests, or feel free to reach out to our [support team](mailto:support@appcues.com).
