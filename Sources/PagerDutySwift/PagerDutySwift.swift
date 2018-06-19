import Dispatch
import Foundation

public struct PagerDuty {
    let baseURL = URL(string: "https://api.pagerduty.com/")!
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let token: String
    
    public func listIncidents(services: [String] = []) {
        var endpoint = "incidents"
        if !services.isEmpty {
            endpoint.append("?")
        }
        for service in services {
            endpoint = "\(endpoint)/\(service)"
        }
        if let incidents = submit(endPoint: endpoint, debug: true) {
            print(incidents)
        }
    }

    // TODO: Implement [pagination](https://v2.developer.pagerduty.com/docs/pagination)
    func submit(endPoint: String, debug: Bool = false) -> String? {
        var request = URLRequest(url: baseURL.appendingPathComponent(endPoint))
        request.setValue("application/vnd.pagerduty+json;version=2", forHTTPHeaderField: "Accept")
        request.setValue("Token token=\(token)", forHTTPHeaderField: "Authorization")

        let sema = DispatchSemaphore(value: 0)
        var responseData: String? = nil
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
                responseData = String(data: data, encoding: .utf8)
            }
            sema.signal()
        }
        task.resume()
        sema.wait()
        return responseData
    }
}
