import Foundation
import NIO
import NIOFoundationCompat
import NIOHTTP1
import NIOHTTPClient

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

/// 📟 PagerDuty API Client
public struct PagerDuty {
    let baseURL = URL(string: "https://api.pagerduty.com/")!
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let decoder = JSONDecoder()
    let token: String
    let client: HTTPClient

    public init(token: String, worker: EventLoopGroup? = nil) {
        let timeout = HTTPClient.Timeout(connect: .seconds(5), read: .seconds(10))
        let configuration = HTTPClient.Configuration.init(timeout: timeout)
        if let worker = worker {
            self.client = HTTPClient(eventLoopGroupProvider: .shared(worker), configuration: configuration)
        } else {
            self.client = HTTPClient(eventLoopGroupProvider: .createNew, configuration: configuration)
        }
        self.token = token
        if #available(OSX 10.12, *) {
            decoder.dateDecodingStrategy = .iso8601
        } else {
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601PD)
        }
    }

    /// Raw request to the PagerDuty API
    private func submit(endPoint: URL, method: HTTPMethod = .GET, body: Data? = nil) throws -> EventLoopFuture<HTTPClient.Response> {
        var request = try HTTPClient.Request(url: endPoint.absoluteString)
        request.method = method
        if method  == .PUT {
            request.headers.add(name: "Content-Type", value: "application/json")
        }
        if let body = body {
            request.body = HTTPClient.Body.data(body)
        }
        request.headers.add(name: "Accept", value: "application/vnd.pagerduty+json;version=2")
        request.headers.add(name: "Authorization", value: "Token token=\(token)")
        return client.execute(request: request)
    }

    /// Send over an HTTP request to PagerDuty
    private func submitRequest<T: Decodable>(url: URLComponents, method: HTTPMethod = .GET, body: Data? = nil) -> EventLoopFuture<T> {
        let requestPromise = self.client.eventLoopGroup.next().makePromise(of: T.self)

        let responseFuture: EventLoopFuture<HTTPClient.Response>
        do {
            responseFuture = try submit(endPoint: url.url!, method: method, body: body)
        } catch {
            requestPromise.fail(error)
            return requestPromise.futureResult
        }
        _ = responseFuture.map { response in
            guard response.status == .ok else {
                //TODO(Yasumoto): Add retries
                requestPromise.fail(PagerDutyError.responseError(errorCode: response.status))
                return
            }
            guard var responseBody = response.body else {
                // TODO: Put in a real error here
                requestPromise.fail(PagerDutyError.responseError(errorCode: .imATeapot))
                return
            }
            guard let data = responseBody.readData(length: responseBody.readableBytes) else {
                // TODO: Real error
                requestPromise.fail(PagerDutyError.responseError(errorCode: .upgradeRequired))
                return
            }
            do {
                let escalationResponse = try self.decoder.decode(T.self, from: data)
                requestPromise.succeed(escalationResponse)
            } catch {
                requestPromise.fail(error)
            }
        }
        return requestPromise.futureResult
    }
}

/// Working with Services
extension PagerDuty {
    /// Get details about an existing service.
    ///
    /// - Parameters:
    ///     - id: Unique identiier for the service
    ///     - include: Array of additional details to include: `escalation_policies` and/or `teams`
    ///
    /// - Returns:
    ///     `Service` with requested fields
    public func getService(id: String, include: [String] = []) -> EventLoopFuture<Service> {
        let endpoint = "/services/\(id)"
        var url = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)!
        url.queryItems = include.map({ URLQueryItem(name: "include [", value: $0) })
        let response: EventLoopFuture<ServiceResponse> = submitRequest(url: url)
        return response.map { $0.service }
    }

    /// Update an existing service.
    ///
    /// - Parameters:
    ///     - service: New service to post
    ///
    /// - Returns:
    ///     The updated `Service`
    public func updateService(service: Service) -> EventLoopFuture<Service> {
        let endpoint = "/services/\(service.id)"
        let url = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)!
        do {
            let data = try JSONEncoder().encode(service)
            let response: EventLoopFuture<ServiceResponse> = submitRequest(url: url, method: .PUT, body: data)
            return response.map { $0.service }
        } catch {
            return self.client.eventLoopGroup.next().makeFailedFuture(error)
        }
    }
}

/// Escalation Policies
extension PagerDuty {
    /// Get information about an existing escalation policy and its rules.
    ///
    /// - Parameters:
    ///     - id: Unique identiier for the escalation policy
    ///     - include: Whether we should also fetch any of `services`, `teams`, or `targets`
    ///
    /// - Returns:
    ///     `EscalationPolicy` with requested fields
    public func getEscalationPolicy(id: String, include: [String] = []) -> EventLoopFuture<EscalationPolicy> {
        let endpoint = "/escalation_policies/\(id)"
        var url = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)!
        url.queryItems = include.map({ URLQueryItem(name: "include [", value: $0) })
        let response: EventLoopFuture<EscalationPolicyResponse> = submitRequest(url: url)
        return response.map { $0.escalationPolicy }
    }
}

/// Incidents
extension PagerDuty {
    // Helper to recursively paginate the list of Incidents
    private func submitListIncidents(url: URLComponents) -> EventLoopFuture<[Incident]> {
        let incidentPromise = self.client.eventLoopGroup.next().makePromise(of: [Incident].self)

        let responseFuture: EventLoopFuture<HTTPClient.Response>
        do {
            responseFuture = try submit(endPoint: url.url!)
        } catch {
            incidentPromise.fail(error)
            return incidentPromise.futureResult
        }
        _ = responseFuture.map { response in
            guard response.status == .ok else {
                //TODO(Yasumoto): Add retries
                incidentPromise.fail(PagerDutyError.responseError(errorCode: response.status))
                return
            }
            guard var responseBody = response.body else {
                // TODO: Put in a real error here
                incidentPromise.fail(PagerDutyError.responseError(errorCode: .imATeapot))
                return
            }
            guard let incidentsData = responseBody.readData(length: responseBody.readableBytes) else {
                // TODO: Real error
                incidentPromise.fail(PagerDutyError.responseError(errorCode: .upgradeRequired))
                return
            }

            do {
                let incidentResponse = try self.decoder.decode(IncidentsResponse.self, from: incidentsData)
                // We're implementing [pagination](https://v2.developer.pagerduty.com/docs/pagination)
                if let moreIncidentsToRetrieve = incidentResponse.more, moreIncidentsToRetrieve == true, let offset = incidentResponse.offset {
                    var newURL = url
                    newURL.queryItems?.append(URLQueryItem(name: "offset", value: "\(incidentResponse.incidents.count + offset)"))
                    self.submitListIncidents(url: newURL).map  { (incidents) -> [Incident] in
                        return incidentResponse.incidents + incidents
                        }.cascade(to: incidentPromise)
                } else {
                    incidentPromise.succeed(incidentResponse.incidents)
                }
            } catch {
                incidentPromise.fail(error)
            }
        }
        return incidentPromise.futureResult
    }

    /// Return incidents matching a given set of filters
    public func listIncidents(services: [String] = [], since: Date? = nil, until: Date? = nil) -> EventLoopFuture<[Incident]> {
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

        return submitListIncidents(url: url)
    }
}
