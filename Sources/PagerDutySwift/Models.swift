//
//  Models.swift
//  PagerDutySwift
//
//  Created by Joseph Mehdi Smith on 6/17/18.
//

public struct Incident {
    id
    string
    optionalread only
    summary
    string
    optionalread onlyA short-form, server-generated string that provides succinct, important information about an object suitable for primary labeling of an entity in a client. In many cases, this will be identical to `name`, though it is not intended to be an identifier.
    type
    string
    Can be incident or incident_reference
    self
    string
    optionalread onlythe API show URL at which the object is accessible
    html_url
    string
    optionalread onlya URL at which the entity is uniquely displayed in the Web app
    incident_number
    integer
    optionalread onlyThe number of the incident. This is unique across your account.
    created_at
    string
    optionalread onlyThe date/time the incident was first triggered.
    status
    string
    optionalThe current status of the incident.Can be triggered, acknowledged or resolved
    title
    string
    optionalA succinct description of the nature, symptoms, cause, or effect of the incident.
    pending_actions
    Array[IncidentAction]
    optionalread onlyThe list of pending_actions on the incident. A pending_action object contains a type of action which can be escalate, unacknowledge, resolve or urgency_change. A pending_action object contains at, the time at which the action will take place. An urgency_change pending_action will contain to, the urgency that the incident will change to.
    incident_key
    string
    optionalread onlyThe incident's de-duplication key.
    service
    ServiceReference
    optionalThe PagerDuty service that the incident belongs to.
    assignments
    Array[Assignment]
    optionalList of all assignments for this incident.
    acknowledgements
    Array[Acknowledgement]
    optionalList of all acknowledgements for this incident.
    last_status_change_at
    string
    optionalread onlyThe time at which the status of the incident last changed.
    last_status_change_by
    Agent
    optionalread onlyThe user or service which is responsible for the incident's last status change. If the incident is in the acknowledged or resolved status, this will be the user that took the first acknowledged or resolved action. If the incident was automatically resolved (say through the Events API), or if the incident is in the triggered state, this will be the incident's service.
    first_trigger_log_entry
    LogEntryReference
    optionalread onlyThe first trigger log entry for the incident.
    escalation_policy
    EscalationPolicyReference
    optionalThe escalation policy that the incident is currently following.
    teams
    Array[TeamReference]
    optionalThe teams involved in the incident’s lifecycle.
    priority
    Priority
    optionalThe priority of the incident.
    urgency
    string
    optionalThe current urgency of the incident.Can be high or low
    resolve_reason
    ResolveReason
    optionalread onlyThe reason the incident was resolved. Currently the only valid values are `nil` and `merged` with plans to introduce additional reasons in the future.
    alert_counts
    AlertCount
    optionalread onlyA summary of the number of alerts by status.
    body
    IncidentBody
    optionalread onlyA JSON object containing data describing the incident.
}

public struct IncidentsResponse {
    offset
    integer
    optionalread onlyEchoes offset pagination property.
    limit
    integer
    optionalread onlyEchoes limit pagination property.
    more
    boolean
    optionalread onlyIndicates if there are additional records to return
    total
    integer
    optionalread onlyThe total number of records matching the given query.
    incidents
    Array[Incident]
}
