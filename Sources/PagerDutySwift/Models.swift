//
//  Models.swift
//  PagerDutySwift
//
//  Created by Joseph Mehdi Smith on 6/17/18.
//

/*public enum IncidentStatus: Codable {
    case triggered, acknowledged, resolved
}*/

/*public enum IncidentUrgency: Codable {
    case high, low
}*/

public struct IncidentAction: Codable {
    /*public enum IncidentActionType: Codable {
        case unacknowledge, escalate, resolve, urgency_change
    }*/

    public let type: String // IncidentActionType

    public let at: String
}

public struct ServiceReference: Codable {
    public let id: String

    // A short-form, server-generated string that provides succinct, important information about an object suitable for primary labeling of an entity in a client. In many cases, this will be identical to `name`, though it is not intended to be an identifier.
    public let summary: String?

    // Can be service or service_reference
    public let type: String?

    // the API show URL at which the object is accessible
    public let selfURL: String?

    // a URL at which the entity is uniquely displayed in the Web app
    // html_url
    public let htmlURL: String?
}

public struct UserReference: Codable {
    public let id: String?

    // A short-form, server-generated string that provides succinct, important information about an object suitable for primary labeling of an entity in a client. In many cases, this will be identical to `name`, though it is not intended to be an identifier.
    public let summary: String?

    // Can be user or user_reference
    public let type: String

    // the API show URL at which the object is accessible
    public let selfURL: String?

    // a URL at which the entity is uniquely displayed in the Web app
    public let htmlURL: String?
}

public struct Assignment: Codable {
    // Time at which the assignment was created.
    public let at: String

    // User that was assigned.
    public let assignee: UserReference
}

public struct Acknowledger: Codable {
    public let id: String?

    // A short-form, server-generated string that provides succinct, important information about an object suitable for primary labeling of an entity in a client. In many cases, this will be identical to `name`, though it is not intended to be an identifier.
    public let summary: String?

    // Can be user, service, user_reference or service_reference
    public let type: String

    // the API show URL at which the object is accessible
    public let selfURL: String?

    // a URL at which the entity is uniquely displayed in the Web app
    public let htmlURL: String?
}

public struct Acknowledgement: Codable {
    // Time at which the acknowledgement was created.
    public let at: String

    // User or service that acknowledged.
    public let acknowledger: Acknowledger
}

public struct Agent: Codable {
    public let id: String?

    // A short-form, server-generated string that provides succinct, important information about an object suitable for primary labeling of an entity in a client. In many cases, this will be identical to `name`, though it is not intended to be an identifier.
    public let summary: String?

    // Can be user, service, integration, user_reference, service_reference or integration_reference
    public let type: String

    // the API show URL at which the object is accessible
    public let selfURL: String?

    // a URL at which the entity is uniquely displayed in the Web app
    public let htmlURL: String?
}

public struct LogEntryReference: Codable {
    public let id: String?

    // A short-form, server-generated string that provides succinct, important information about an object suitable for primary labeling of an entity in a client. In many cases, this will be identical to `name`, though it is not intended to be an identifier.
    public let summary: String?

    // Can be acknowledge_log_entry, acknowledge_log_entry_reference, annotate_log_entry, annotate_log_entry_reference, assign_log_entry, assign_log_entry_reference, escalate_log_entry, escalate_log_entry_reference, exhaust_escalation_path_log_entry, exhaust_escalation_path_log_entry_reference, notify_log_entry, notify_log_entry_reference, reach_trigger_limit_log_entry, reach_trigger_limit_log_entry_reference, repeat_escalation_path_log_entry, repeat_escalation_path_log_entry_reference, resolve_log_entry, resolve_log_entry_reference, snooze_log_entry, snooze_log_entry_reference, trigger_log_entry, trigger_log_entry_reference, unacknowledge_log_entry or unacknowledge_log_entry_reference
    public let type: String

    // the API show URL at which the object is accessible
    public let selfURL: String?

    // a URL at which the entity is uniquely displayed in the Web app
    public let htmlURL: String?
}

public struct EscalationPolicyReference: Codable {
    public let id: String?

    // A short-form, server-generated string that provides succinct, important information about an object suitable for primary labeling of an entity in a client. In many cases, this will be identical to `name`, though it is not intended to be an identifier.
    public let summary: String?

    // Can be escalation_policy or escalation_policy_reference
    public let type: String

    // the API show URL at which the object is accessible
    public let selfURL: String?

    // a URL at which the entity is uniquely displayed in the Web app
    public let htmlURL: String?
}

public struct TeamReference: Codable {
    public let id: String?

    // A short-form, server-generated string that provides succinct, important information about an object suitable for primary labeling of an entity in a client. In many cases, this will be identical to `name`, though it is not intended to be an identifier.
    public let summary: String?

    // Can be team or team_reference
    public let type: String

    // the API show URL at which the object is accessible
    public let selfURL: String?

    // a URL at which the entity is uniquely displayed in the Web app
    public let htmlURL: String?
}

public struct Priority: Codable {
    public let id: String?

    // A short-form, server-generated string that provides succinct, important information about an object suitable for primary labeling of an entity in a client. In many cases, this will be identical to `name`, though it is not intended to be an identifier.
    public let summary: String?

    // Can be priority or priority_reference
    public let type: String

    // the API show URL at which the object is accessible
    public let selfURL: String?

    // a URL at which the entity is uniquely displayed in the Web app
    public let htmlURL: String?

    // The user-provided short name of the priority.
    public let name: String?

    // The user-provided description of the priority.
    public let description: String?
}

public struct IncidentReference: Codable {
    public let id: String?

    // A short-form, server-generated string that provides succinct, important information about an object suitable for primary labeling of an entity in a client. In many cases, this will be identical to `name`, though it is not intended to be an identifier.
    public let summary: String?

    // Can be incident or incident_reference
    public let type: String

    // the API show URL at which the object is accessible
    public let selfURL: String?

    // a URL at which the entity is uniquely displayed in the Web app
    public let htmlURL: String?
}

public struct ResolveReason: Codable {
    // The reason the incident was resolved. The only reason currently supported is merge.Can be merge_resolve_reason,
    public let type: String?

    public let incident: IncidentReference?
}

public struct AlertCount: Codable {
    // The count of triggered alerts
    public let triggered: Int?

    // The count of resolved alerts
    public let resolved: Int?

    // The total count of alerts
    public let all: Int?
}

public struct IncidentBody: Codable {
    // Can be incident_body,
    public let type: String

    // Additional incident details.
    public let details: String?
}

public struct Incident: Codable {
    public let id: String?

    // A short-form, server-generated string that provides succinct, important information about an object suitable for primary labeling of an entity in a client. In many cases, this will be identical to `name`, though it is not intended to be an identifier.
    public let summary: String?

    // Can be incident or incident_reference
    public let type: String

    // the API show URL at which the object is accessible
    // self
    public let selfURL: String?

    // a URL at which the entity is uniquely displayed in the Web app
    // html_url
    public let htmlURL: String?

    // The number of the incident. This is unique across your account.
    // incident_number
    public let incidentNumber: Int?

    // The date/time the incident was first triggered.
    // created_at
    public let createdAt: String?

    // The current status of the incident.Can be triggered, acknowledged or resolved
    public let status: String? //IncidentStatus?

    // A succinct description of the nature, symptoms, cause, or effect of the incident.
    public let title: String?

    // The list of pending_actions on the incident. A pending_action object contains a type of action which can be escalate, unacknowledge, resolve or urgency_change. A pending_action object contains at, the time at which the action will take place. An urgency_change pending_action will contain to, the urgency that the incident will change to.
    // pending_actions
    public let pendingActions: [IncidentAction]?

    // The incident's de-duplication key.
    // incident_key
    public let incidentKey: String?

    // The PagerDuty service that the incident belongs to.
    public let service: ServiceReference?

    // List of all assignments for this incident.
    public let assignments: [Assignment]?

    // List of all acknowledgements for this incident.
    public let acknowledgements: [Acknowledgement]?

    // The time at which the status of the incident last changed.
    // last_status_change_at
    public let lastStatusChangeAt: String?

    // The user or service which is responsible for the incident's last status change. If the incident is in the acknowledged or resolved status, this will be the user that took the first acknowledged or resolved action. If the incident was automatically resolved (say through the Events API), or if the incident is in the triggered state, this will be the incident's service.
    // last_status_change_by
    public let lastStatusChangeBy: Agent?

    // The first trigger log entry for the incident.
    // first_trigger_log_entry
    public let firstTriggerLogEntry: LogEntryReference?

    // The escalation policy that the incident is currently following.
    // escalation_policy
    public let escalationPolicy: EscalationPolicyReference?

    // The teams involved in the incident’s lifecycle.
    public let teams: [TeamReference]?

    // The priority of the incident.
    public let priority: Priority?

    // The current urgency of the incident.Can be high or low
    public let urgency: String?

    // The reason the incident was resolved. Currently the only valid values are `nil` and `merged` with plans to introduce additional reasons in the future.
    // resolve_reason
    public let resolveReason: ResolveReason?

    // A summary of the number of alerts by status.
    // alert_counts
    public let alertCounts: AlertCount?

    // A JSON object containing data describing the incident.
    public let body: IncidentBody?
}

public struct IncidentsResponse: Codable {
    // Echoes offset pagination property.
    public let offset: Int?

    // Echoes limit pagination property.
    public let limit: Int?

    // Indicates if there are additional records to return
    public let more: Bool?

    // The total number of records matching the given query.
    public let total: Int?

    public let incidents: [Incident]
}
