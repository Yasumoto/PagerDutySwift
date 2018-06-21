import Dispatch
import Foundation

extension DateFormatter {
    static let iso8601PD: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

public struct PagerDuty {
    let baseURL = URL(string: "https://api.pagerduty.com/")!
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let token: String
    let decoder = JSONDecoder()

    public init(token: String) {
        self.token = token
        if #available(OSX 10.12, *) {
            decoder.dateDecodingStrategy = .iso8601
        } else {
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601PD)
        }
    }

    // Return incidents matching a given set of filters
    public func listIncidents(services: [String] = [], since: Date? = nil, until: Date? = nil) -> [Incident] {
        let endpoint = "incidents"
        var url = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)!
        url.queryItems = services.map({ URLQueryItem(name: "service_ids[]", value: $0) })
        if let since = since {
            url.queryItems?.append(URLQueryItem(name: "since", value:         DateFormatter.iso8601PD.string(from: since)))
        }
        if let until = until {
            url.queryItems?.append(URLQueryItem(name: "until", value:         DateFormatter.iso8601PD.string(from: until)))
        }
        // PD docs say enabling the following will slow the response
        // but this will give us the total value
        //url.queryItems?.append(URLQueryItem(name: "total", value: "true"))

        var more = true
        var incidents = [Incident]()
        while more {
            if let incidentsData = submit(endPoint: url.url!) {
                do {
                    let response = try decoder.decode(IncidentsResponse.self, from: incidentsData)
                    incidents.append(contentsOf: response.incidents)
                    if let moreIncidentsToRetrieve = response.more {
                        more = moreIncidentsToRetrieve
                        url.queryItems?.append(URLQueryItem(name: "offset", value: "\(incidents.count)"))
                    } else {
                        more = false
                    }
                } catch {
                    print("Could not retrieve incidents: \(error)")
                }
            }
        }
        return incidents
    }

    // TODO: Implement [pagination](https://v2.developer.pagerduty.com/docs/pagination)
    func submit(endPoint: URL, debug: Bool = false) -> Data? {
        var request = URLRequest(url: endPoint)
        request.setValue("application/vnd.pagerduty+json;version=2", forHTTPHeaderField: "Accept")
        request.setValue("Token token=\(token)", forHTTPHeaderField: "Authorization")

        let sema = DispatchSemaphore(value: 0)
        var responseData: Data? = nil
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error connecting to PagerDuty: \(error)")
            }
            if let response = response {
                if debug == true {
                    print("Response: \(response)")
                }
            }
            if let data = data {
                responseData = data
            }
            sema.signal()
        }
        task.resume()
        sema.wait()
        return responseData
    }
}
