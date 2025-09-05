import Foundation
import Combine

protocol RandomUserServiceProtocol {
    func fetch(page: Int) -> AnyPublisher<[RemoteUser], Error>
}

final class RandomUserService: RandomUserServiceProtocol {
    private let api: APIClientProtocol
    init(apiClient: APIClientProtocol = APIClient()) { self.api = apiClient }

    func fetch(page: Int) -> AnyPublisher<[RemoteUser], Error> {
        return api.fetchMatches(page: page, results: Constants.resultsPerPage)
    }
}
