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
    let accountId: String
    let applicationId: String
}

/// An implementation of the Appcues device mode destination as a plugin.
public class AppcuesDestination: DestinationPlugin {
    public let timeline = Timeline()
    public let key = "Appcues Mobile"
    public let type = PluginType.destination
    public var analytics: Analytics?

    public private(set) var appcues: Appcues?

    private var configuration: ((Appcues.Config) -> Void)?

    public init(configuration: ((Appcues.Config) -> Void)? = nil) {
        self.configuration = configuration
    }

    public func update(settings: Settings, type: UpdateType) {
        guard type == .initial else { return }

        guard let appcuesSettings: AppcuesSettings = settings.integrationSettings(forPlugin: self) else {
            analytics?.log(message: "\(key) destination is disabled via settings")
            return
        }
        let config = Appcues.Config(accountID: appcuesSettings.accountId, applicationID: appcuesSettings.applicationId)
            .apply(configuration)
            .additionalAutoProperties(["_segmentVersion": analytics?.version() ?? "unknown"])

        appcues = Appcues(config: config)
        analytics?.log(message: "\(key) destination loaded")
    }

    public func identify(event: IdentifyEvent) -> IdentifyEvent? {
        if let appcues = appcues, let userId = event.userId, !userId.isEmpty {
            appcues.identify(userID: userId, properties: event.traits?.appcuesProperties)
        }
        return event
    }

    public func track(event: TrackEvent) -> TrackEvent? {
        if let appcues = appcues, event.isValid {
            appcues.track(name: event.event, properties: event.properties?.appcuesProperties)
        }
        return event
    }

    public func screen(event: ScreenEvent) -> ScreenEvent? {
        if let appcues = appcues, let title = event.title {
            appcues.screen(title: title, properties: event.properties?.appcuesProperties)
        }
        return event
    }

    public func group(event: GroupEvent) -> GroupEvent? {
        if let appcues = appcues, let groupID = event.groupId, !groupID.isEmpty {
            appcues.group(groupID: groupID, properties: event.traits?.appcuesProperties)
        }
        return event
    }

    public func reset() {
        guard let appcues = appcues else { return }
        appcues.reset()
    }
}

private extension TrackEvent {
    var isValid: Bool {
        // not a valid appcues event if the name is empty, or if it is re-tracking an internal event
        // prefixed with "appcues:"
        !event.isEmpty && !event.lowercased().starts(with: "appcues:")
    }
}

private extension ScreenEvent {
    var title: String? {
        // return the valid appcues screen, if available, or nil. If the screen title is nil or empty, or
        // is retracking an internal screen event prefixed with "appcues:", it is ignored
        guard let title = name, !title.isEmpty && !title.lowercased().starts(with: "appcues:") else { return nil }
        return title
    }
}

private extension Appcues.Config {
    func apply(_ configuration: ((Appcues.Config) -> Void)?) -> Self {
        configuration?(self)
        return self
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
