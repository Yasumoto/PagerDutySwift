import Foundation
import NIO
import NIOFoundationCompat
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

    // Return incidents matching a given set of filters
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

    // TODO: Implement [pagination](https://v2.developer.pagerduty.com/docs/pagination)
    func submit(endPoint: URL, debug: Bool = false) throws -> EventLoopFuture<HTTPClient.Response> {
        var request = try HTTPClient.Request(url: endPoint.absoluteString)
        request.headers.add(name: "Accept", value: "application/vnd.pagerduty+json;version=2")
        request.headers.add(name: "Authorization", value: "Token token=\(token)")
        return client.execute(request: request)
    }
}
