import Foundation
import Combine

protocol APIClientProtocol {
    func fetchMatches(page: Int, results: Int) -> AnyPublisher<[RemoteUser], Error>
}

final class APIClient: APIClientProtocol {
    private let session: URLSession
    init(session: URLSession = .shared) { self.session = session }

    func fetchMatches(page: Int, results: Int) -> AnyPublisher<[RemoteUser], Error> {
        var comps = URLComponents(url: Constants.baseURL, resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "results", value: String(results)),
            URLQueryItem(name: "page", value: String(page))
        ]
        let request = URLRequest(url: comps.url!)
        return session.dataTaskPublisher(for: request)
            .mapError { $0 as Error }
            .retry(2)
            .tryMap { data, resp in
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(RemoteUserResponse.self, from: data)
                return response.results
            }
            .eraseToAnyPublisher()
    }
}
