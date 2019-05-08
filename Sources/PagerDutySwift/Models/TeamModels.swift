//
//  TeamModels.swift
//  PagerDutySwift
//
//  Created by Joe Smith on 5/7/19.
//

/// A team is a collection of [users](https://api-reference.pagerduty.com/#resource_Users) and [escalation policies](https://api-reference.pagerduty.com/#resource_Escalation_Policies) that represent a group of people within an organization.
///
/// Teams can be used throughout the API and PagerDuty applications to filter information to only what is relevant for one or more teams.
///
/// The account must have the teams ability to use the following endpoints.
public struct Team: Codable {
    public let id: String

    /// Can be team or team_reference
    public let type: String

    /// A short-form, server-generated string that provides succinct, important information about an object suitable for primary labeling of an entity in a client. In many cases, this will be identical to `name`, though it is not intended to be an identifier
    public let summary: String

    /// the API show URL at which the object is accessible
    public let selfUrl: String

    /// a URL at which the entity is uniquely displayed in the Web app
    public let htmlUrl: String

    /// The name of the team.
    public let name: String

    /// The description of the team.
    public let description: String
    public let defaultRole: String

    private enum CodingKeys: String, CodingKey {
        case id, type, summary, name, description
        case selfUrl = "self_url"
        case htmlUrl = "html_url"
        case defaultRole = "default_role"
    }
}
