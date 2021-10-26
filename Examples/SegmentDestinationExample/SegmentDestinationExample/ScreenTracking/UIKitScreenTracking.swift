// Adapted from Source:
// https://github.com/segmentio/analytics-swift/blob/main/Examples/other_plugins/UIKitScreenTracking.swift
//
//  UIKitScreenTracking.swift
//  SegmentUIKitExample
//
//  Created by Brandon Sneed on 4/13/21.
//

// NOTE: You can see this plugin in use in the SwiftUIKitExample application.
//
// This plugin is NOT SUPPORTED by Segment.  It is here merely as an example,
// and for your convenience should you find it useful.

// MIT License
//
// Copyright (c) 2021 Segment
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// swiftlint:disable all

import Foundation
import Segment
import UIKit

/**
 Example plugin to replicate automatic screen tracking in iOS.
 */

class UIKitScreenTracking: UtilityPlugin {
    static let notificationName = Notification.Name(rawValue: "UIKitScreenTrackNotification")
    static let screenNameKey = "name"
    static let controllerKey = "controller"

    let type = PluginType.utility
    var analytics: Analytics? = nil

    private var lastScreen: String? = nil

    init() {
        setupUIKitHooks()
    }

    internal func setupUIKitHooks() {
        swizzle(forClass: UIViewController.self,
                original: #selector(UIViewController.viewDidAppear(_:)),
                new: #selector(UIViewController.seg__viewDidAppear)
        )

        NotificationCenter.default.addObserver(forName: Self.notificationName, object: nil, queue: OperationQueue.main) { notification in
            guard let name = notification.userInfo?[Self.screenNameKey] as? String,
                  self.lastScreen != name else {
                      return
                  }
            self.lastScreen = name
            self.analytics?.screen(title: name)
        }
    }
}

extension UIKitScreenTracking {
    private func swizzle(forClass: AnyClass, original: Selector, new: Selector) {
        guard let originalMethod = class_getInstanceMethod(forClass, original) else { return }
        guard let swizzledMethod = class_getInstanceMethod(forClass, new) else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension UIViewController {
    internal func activeController() -> UIViewController? {
        // if a view is being dismissed, this will return nil
        if let root = viewIfLoaded?.window?.rootViewController {
            return root
        } else if #available(iOS 13.0, *) {
            // preferred way to get active controller in ios 13+
            for scene in UIApplication.shared.connectedScenes {
                if scene.activationState == .foregroundActive {
                    let windowScene = scene as? UIWindowScene
                    let sceneDelegate = windowScene?.delegate as? UIWindowSceneDelegate
                    if let target = sceneDelegate, let window = target.window {
                        return window?.rootViewController
                    }
                }
            }
        } else {
            // this was deprecated in ios 13.0
            return UIApplication.shared.keyWindow?.rootViewController
        }
        return nil
    }

    internal func captureScreen() {
        var rootController = viewIfLoaded?.window?.rootViewController
        if rootController == nil {
            rootController = activeController()
        }
        guard let top = Self.seg__visibleViewController(activeController()) else { return }

        var name = String(describing: top.self.classForCoder).replacingOccurrences(of: "ViewController", with: "")

        // name could've been just "ViewController"...
        if name.count == 0 {
            name = top.title ?? "Unknown"
        }

        // post a notification that our plugin can capture.
        // if you were to do a custom implementation of how the name should
        // appear, you probably want to inspect the viewcontroller itself, `top` in this
        // case to generate your string for name and/or category.
        NotificationCenter.default.post(name: UIKitScreenTracking.notificationName,
                                        object: self,
                                        userInfo: [UIKitScreenTracking.screenNameKey: name,
                                                   UIKitScreenTracking.controllerKey: top])
    }

    @objc internal func seg__viewDidAppear(animated: Bool) {
        captureScreen()
        // it looks like we're calling ourselves, but we're actually
        // calling the original implementation of viewDidAppear since it's been swizzled.
        seg__viewDidAppear(animated: animated)
    }

    static func seg__visibleViewController(_ controller: UIViewController?) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return seg__visibleViewController(navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return seg__visibleViewController(selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return seg__visibleViewController(presented)
        }
        return controller
    }
}
