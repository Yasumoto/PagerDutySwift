//
//  ServiceModels.swift
//  PagerDutySwift
//
//  Created by Joe Smith on 5/7/19.
//

/// A PagerDuty service represents something you monitor (like a web service, email service, or database service). It is a container for related [incidents](https://api-reference.pagerduty.com/#resource_Incidents) that associates them with [escalation policies](https://api-reference.pagerduty.com/#resource_Escalation_Policies).
///
/// A service is the focal point for incident management; services specify the configuration for the behavior of incidents triggered on them. This behavior includes specifying urgency and performing automated actions based on time of day, incident duration, and other factors.
public struct Service: Codable {
    public let id: String

    /// A short-form, server-generated string that provides succinct, important information about an object suitable for primary labeling of an entity in a client. In many cases, this will be identical to `name`, though it is not intended to be an identifier.
    public let summary: String

    /// Can be service or service_reference
    public let type: String

    /// The name of the service.
    public let name: String

    /// Time in seconds that an incident is automatically resolved if left open for that long. Value is `null` if the feature is disabled. Value must not be negative. Setting this field to `0`, `null` (or unset in POST request) will disable the feature.
    public let autoResolveTimeout: Int

    /// Time in seconds that an incident changes to the Triggered State after being Acknowledged. Value is `null` if the feature is disabled. Value must not be negative. Setting this field to `0`, `null` (or unset in POST request) will disable the feature.
    public let acknowledgementTimeout: Int

    private enum CodingKeys: String, CodingKey {
        case id, summary, type, name
        case autoResolveTimeout = "auto_resolve_timeout"
        case acknowledgementTimeout = "acknowledgement_timeout"
    }
}

public struct ServiceResponse: Codable {
    public let service: Service
}
