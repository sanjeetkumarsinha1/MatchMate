import Foundation
import Combine

final class MatchListViewModel: ObservableObject {
    @Published private(set) var matches: [Match] = []
    @Published var isLoadingPage = false
    @Published var errorMessage: String?

    private var currentPage = 1
    private var cancellables = Set<AnyCancellable>()
    private let service: RandomUserServiceProtocol
    private let repo: MatchRepositoryProtocol
    private let reach = ReachabilitySimulator.shared

    init(service: RandomUserServiceProtocol = RandomUserService(),
         repo: MatchRepositoryProtocol = MatchRepository()) {
        self.service = service
        self.repo = repo
        bindRepository()
        loadCached()
    }

    private func bindRepository() {
        repo.fetchAll()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.matches = items
            }
            .store(in: &cancellables)
    }

    func loadCached() {
        // triggers fetchAll via repository binding
    }

    func loadNextPageIfNeeded(currentItem: Match?) {
        guard let item = currentItem else { fetchNextPage(); return }
        let thresholdIndex = matches.index(matches.endIndex, offsetBy: -3)
        if let idx = matches.firstIndex(where: { $0.id == item.id }), idx >= thresholdIndex {
            fetchNextPage()
        }
    }

    func fetchNextPage() {
        guard !isLoadingPage else { return }
        isLoadingPage = true
        let next = currentPage + 1
        service.fetch(page: next)
            .flatMap { [weak self] remote -> AnyPublisher<[Match], Error> in
                guard let self = self else { return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher() }
                return self.repo.save(remoteUsers: remote, page: next)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoadingPage = false
                switch completion {
                case .failure(let err):
                    self?.errorMessage = err.localizedDescription
                    // keep cached items
                case .finished:
                    self?.currentPage = next
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func fetchNextPageInitial() {
        // used to fetch page 1 initially
        guard !isLoadingPage else { return }
        isLoadingPage = true
        let page = currentPage
        service.fetch(page: page)
            .flatMap { [weak self] remote -> AnyPublisher<[Match], Error> in
                guard let self = self else { return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher() }
                return self.repo.save(remoteUsers: remote, page: page)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoadingPage = false
                switch completion {
                case .failure(let err):
                    self?.errorMessage = err.localizedDescription
                case .finished:
                    break
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func accept(id: String) {
        _ = repo.updateStatus(id: id, status: .accepted)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // handle
            } receiveValue: { match in
                // optimistic update handled by CoreData binding
            }
    }

    func decline(id: String) {
        _ = repo.updateStatus(id: id, status: .declined)
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { match in }
    }
}
