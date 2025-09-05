import Foundation
import CoreData
import Combine

final class SyncManager {
    static let shared = SyncManager()
    private var cancellables = Set<AnyCancellable>()
    private let repo: MatchRepositoryProtocol
    private let reach = ReachabilitySimulator.shared

    init(repo: MatchRepositoryProtocol = MatchRepository()) {
        self.repo = repo
        reach.$isOnline
            .sink { [weak self] online in
                if online { self?.syncPending() }
            }.store(in: &cancellables)
    }

    func syncPending() {
        let pending = repo.fetchPendingSync()
        for item in pending {
            _ = repo.updateStatus(id: item.id, status: item.status)
                .sink(receiveCompletion: { _ in }, receiveValue: { m in
                    let ctx = CoreDataStack.shared.container.viewContext
                    let fetch: NSFetchRequest<MatchEntity> = MatchEntity.fetchRequest()
                    fetch.predicate = NSPredicate(format: "id == %@", m.id)
                    if let ent = (try? ctx.fetch(fetch))?.first {
                        ent.pendingSync = false
                        try? ctx.save()
                    }
                })
        }
    }
}
