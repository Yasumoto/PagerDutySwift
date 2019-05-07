//
//  TeamModels.swift
//  PagerDutySwift
//
//  Created by Joe Smith on 5/7/19.
//

public struct Team: Codable {
    /*public enum TeamType: Codable {
        public init(from decoder: Decoder) throws {
            let values = decoder.container(keyedBy: CodableKeys.self)
            if let teamID = try? values.deco
        }

        public func encode(to encoder: Encoder) throws {
            <#code#>
        }

        case team: String
        case teamReference: String

        private enum CodingKeys: String, CodingKey {
            case team
            case teamReference = "team_reference"
        }
    }*/

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
