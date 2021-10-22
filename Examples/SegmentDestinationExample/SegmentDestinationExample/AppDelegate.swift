//
//  AppDelegate.swift
//  SegmentDestinationExample
//
//  Created by James Ellis on 10/13/21.
//

import UIKit
import Segment
import SegmentAppcues

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Add the Appcues destination plugin
        Analytics.shared.add(plugin: AppcuesDestination())

        // Add Segment automatic screen tracking plugin
        Analytics.shared.add(plugin: UIKitScreenTracking())

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after
        // application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

extension Analytics {
    static var shared = Analytics(configuration: Configuration(writeKey: <#SEGMENT_WRITE_KEY#>)
                                    .flushAt(1)
                                    .trackApplicationLifecycleEvents(true))
}
