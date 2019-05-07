//
//  EscalationPolicyModels.swift
//  PagerDutySwift
//
//  Created by Joe Smith on 5/7/19.
//

public struct EscalationTarget: Codable {
    public let id: String?
    public let summary: String
    public let type: String
    public let selfUrl: String
    public let htmlUrl: String

    private enum CodingKeys: String, CodingKey {
        case id, summary, type
        case selfUrl = "self"
        case htmlUrl = "html_url"
    }

}

public struct EscalationRule: Codable {
    public let id: String?
    public let escalationDelayInMinutes: Int
    public let targets: [EscalationTarget]

    private enum CodingKeys: String, CodingKey {
        case id, targets
        case escalationDelayInMinutes = "escalation_delay_in_minutes"
    }
}

public struct EscalationPolicy: Codable {
    public let id: String?

    /// Can be escalation_policy or escalation_policy_reference
    public let type: String

    /// A short-form, server-generated string that provides succinct, important information about an object suitable for primary labeling of an entity in a client. In many cases, this will be identical to `name`, though it is not intended to be an identifier.
    public let summary: String?

    /// the API show URL at which the object is accessible
    public let selfUrl: String

    /// a URL at which the entity is uniquely displayed in the Web app
    public let htmlUrl: String

    /// The name of the escalation policy.
    public let name: String
    public let escalationRules: [EscalationRule]
    public let services: [ServiceReference]

    /// The number of times the escalation policy will repeat after reaching the end of its escalation.
    public let numLoops: Int

    /// Teams associated with the policy. Account must have the `teams` ability to use this parameter.
    public let teams: [TeamReference]

    /// Escalation policy description.
    public let description: String
    private enum CodingKeys: String, CodingKey {
        case id, type, summary, name, services, teams,  description
        case selfUrl = "self"
        case htmlUrl = "html_url"
        case escalationRules = "escalation_rules"
        case numLoops = "num_loops"
    }
}

public struct EscalationPolicyResponse: Codable {
    public let escalationPolicy: EscalationPolicy

    private enum CodingKeys: String, CodingKey {
        case escalationPolicy = "escalation_policy"
    }
}
