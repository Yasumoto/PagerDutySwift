# PagerDutySwift

Client library for [PagerDuty](https://pagerduty.com) written in Swift.

## Example

```swift
import PagerDutySwift

guard let token = ProcessInfo.processInfo.environment["PAGERDUTY_TOKEN"] else {
    print("Please set the PAGERDUTY_TOKEN environment variable with a valid API token.")
    exit(1)
}

let client = PagerDuty(token: token)

var threeDays = DateComponents()
threeDays.hour = -3
let calendar = Calendar(identifier: .gregorian)
let incidents = try client.listIncidents(since: calendar.date(byAdding: threeDays, to: Date())).wait()
for incident in incidents {
    print("Summary: \(String(describing: incident.summary))")
}
```
