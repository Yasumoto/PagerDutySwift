import Dispatch
import Foundation

public struct PagerDuty {
    let baseURL = URL(string: "https://api.pagerduty.com/")!
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let token: String
    let decoder = JSONDecoder()
    
    // https://api.pagerduty.com/incidents?service_ids%5B%5D=testing&time_zone=UTC
    public func listIncidents(services: [String] = []) -> IncidentsResponse? {
        let endpoint = "incidents"
        var url = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)!
        url.queryItems = services.map({ URLQueryItem(name: "service_ids[]", value: $0) })

        if let incidentsData = submit(endPoint: url.url!, debug: true) {
            do {
                let incidents = try decoder.decode(IncidentsResponse.self, from: incidentsData)
                return(incidents)
            } catch {
                print("Could not retrieve incidents: \(error)")
            }
        }
        return nil
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
