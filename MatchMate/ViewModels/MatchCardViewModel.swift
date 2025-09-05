import Foundation
import Combine

final class MatchCardViewModel: ObservableObject, Identifiable {
    @Published var match: Match
    private let repo: MatchRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    var id: String { match.id }

    init(match: Match, repo: MatchRepositoryProtocol = MatchRepository()) {
        self.match = match
        self.repo = repo
    }

    func accept() {
        repo.updateStatus(id: match.id, status: .accepted)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] m in
                self?.match = m
            })
            .store(in: &cancellables)
    }

    func decline() {
        repo.updateStatus(id: match.id, status: .declined)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] m in
                self?.match = m
            })
            .store(in: &cancellables)
    }
}

