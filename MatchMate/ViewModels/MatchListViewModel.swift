import Foundation
import Combine

final class MatchListViewModel: ObservableObject {
    // stable array of card viewmodels used by the List
    @Published var cardViewModels: [MatchCardViewModel] = []
    @Published var isLoadingPage = false
    @Published var errorMessage: String?

    private var currentPage = 1
    private var cancellables = Set<AnyCancellable>()
    private let service: RandomUserServiceProtocol
    private let repo: MatchRepositoryProtocol
    private let reach = ReachabilitySimulator.shared
    private var canLoadMorePages = true

    init(service: RandomUserServiceProtocol = RandomUserService(),
         repo: MatchRepositoryProtocol = MatchRepository()) {
        self.service = service
        self.repo = repo
        bindRepository()
        fetchNextPageInitial()
    }

    // Bind Core Data -> matches and keep cardViewModels stable (reuse by id)
    private func bindRepository() {
        repo.fetchAll()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self = self else { return }
                self.syncCardViewModels(with: items)
            }
            .store(in: &cancellables)
    }

    // Reuse existing VMs by id; update match inside VM when available
    private func syncCardViewModels(with matches: [Match]) {
        var existingById = Dictionary(uniqueKeysWithValues: cardViewModels.map { ($0.id, $0) })
        var newList: [MatchCardViewModel] = []

        for match in matches {
            if let vm = existingById[match.id] {
                // update existing VM with new Match model (keeps identity)
                DispatchQueue.main.async {
                    vm.match = match
                }
                newList.append(vm)
                existingById.removeValue(forKey: match.id)
            } else {
                // create new VM
                let vm = MatchCardViewModel(match: match, repo: repo)
                newList.append(vm)
            }
        }
        // replace array (preserves VMs that still exist)
        self.cardViewModels = newList
    }

    // Public - reset & fetch page 1
    func fetchNextPageInitial() {
        guard !isLoadingPage else { return }
        isLoadingPage = true
        currentPage = 1
        canLoadMorePages = true

        service.fetch(page: currentPage)
            .flatMap { [weak self] remoteUsers -> AnyPublisher<[Match], Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "self_nil", code: -1)).eraseToAnyPublisher()
                }
                return self.repo.save(remoteUsers: remoteUsers, page: self.currentPage)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingPage = false
                if case .failure(let err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                // repo.fetchAll binding will populate cardViewModels
            }
            .store(in: &cancellables)
    }

    // Load next page (pagination)
    func loadNextPageIfNeeded(currentItem: Match) {
        guard canLoadMorePages, !isLoadingPage else { return }
        // If currentItem is last one, fetch next page
        if let lastMatch = cardViewModels.last?.match, lastMatch.id == currentItem.id {
            fetchPage(page: currentPage + 1)
        }
    }

    private func fetchPage(page: Int) {
        guard !isLoadingPage else { return }
        isLoadingPage = true

        service.fetch(page: page)
            .flatMap { [weak self] remoteUsers -> AnyPublisher<[Match], Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "self_nil", code: -1)).eraseToAnyPublisher()
                }
                return self.repo.save(remoteUsers: remoteUsers, page: page)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoadingPage = false
                switch completion {
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                case .finished:
                    self.currentPage = page
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}

