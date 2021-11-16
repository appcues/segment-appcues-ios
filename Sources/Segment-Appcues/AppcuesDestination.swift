//
//  AppcuesDestination.swift
//  SegmentAppcues
//
//  Created by James Ellis on 10/13/21.
//

import Foundation
import Segment
import AppcuesKit

private struct AppcuesSettings: Codable {
    let appcuesId: String
}

/// An implementation of the Appcues device mode destination as a plugin.
public class AppcuesDestination: DestinationPlugin {
    public let timeline = Timeline()
    public let key = "Appcues"
    public let type = PluginType.destination
    public var analytics: Analytics?

    public private(set) var appcues: Appcues?

    public init() {
    }

    public func update(settings: Settings, type: UpdateType) {
        guard let appcuesSettings: AppcuesSettings = settings.integrationSettings(forPlugin: self) else { return }
        appcues = Appcues(config: Appcues.Config(accountID: appcuesSettings.appcuesId))
    }

    public func identify(event: IdentifyEvent) -> IdentifyEvent? {
        if let appcues = appcues, let userId = event.userId {
            appcues.identify(userID: userId, properties: event.traits?.appcuesProperties)
        }
        return event
    }

    public func track(event: TrackEvent) -> TrackEvent? {
        if let appcues = appcues {
            appcues.track(name: event.event, properties: event.properties?.appcuesProperties)
        }
        return event
    }

    public func screen(event: ScreenEvent) -> ScreenEvent? {
        if let appcues = appcues, let title = event.name {
            appcues.screen(title: title, properties: event.properties?.appcuesProperties)
        }
        return event
    }

    public func reset() {
        guard let appcues = appcues else { return }
        appcues.reset()
    }
}

private extension JSON {
    // The underlying Appcues API can support strings, numbers, or booleans.
    // See: https://docs.appcues.com/article/161-javascript-api
    //
    // The Appcues SDK also allows URL and Date values that get converted
    // internally.  Any other more complex custom property types sent through
    // the Segment plugin must be filtered out.
    var appcuesProperties: [String: Any]? {
        guard let properties = dictionaryValue else { return nil }
        return properties.compactMapValues { value in
            guard value is String ||
                    value is URL ||
                    value is Bool ||
                    // swiftlint:disable:next legacy_objc_type
                    value is NSNumber ||
                    value is Date else {
                        return nil
                    }
            return value
        }
    }
}
