import Foundation
import CoreData
import Combine

protocol MatchRepositoryProtocol {
    func save(remoteUsers: [RemoteUser], page: Int) -> AnyPublisher<[Match], Error>
    func fetchAll() -> AnyPublisher<[Match], Never>
    func updateStatus(id: String, status: Match.MatchStatus) -> AnyPublisher<Match, Error>
    func fetchPendingSync() -> [Match]
}

final class MatchRepository: MatchRepositoryProtocol {
    private let ctx: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.container.viewContext) {
        self.ctx = context
    }

    func save(remoteUsers: [RemoteUser], page: Int) -> AnyPublisher<[Match], Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            self.ctx.perform {
                var saved: [Match] = []
                for r in remoteUsers {
                    let id = r.login.uuid
                    let fetch: NSFetchRequest<MatchEntity> = MatchEntity.fetchRequest()
                    fetch.predicate = NSPredicate(format: "id == %@", id)
                    if ((try? self.ctx.fetch(fetch))?.first) != nil {
                        continue
                    }
                    let ent = MatchEntity(context: self.ctx)
                    ent.id = id
                    ent.firstName = r.name.first
                    ent.lastName = r.name.last
                    ent.age = Int16(r.dob.age)
                    ent.city = r.location.city
                    ent.country = r.location.country
                    ent.thumbnailURL = r.picture.thumbnail
                    ent.status = Match.MatchStatus.none.rawValue
                    ent.pendingSync = false
                    ent.page = Int16(page)
                    ent.createdAt = Date()
                    saved.append(Match(id: ent.id,
                                       firstName: ent.firstName ?? "",
                                       lastName: ent.lastName ?? "",
                                       age: Int(ent.age),
                                       city: ent.city ?? "",
                                       country: ent.country ?? "",
                                       thumbnailURL: ent.thumbnailURL ?? "",
                                       status: .none,
                                       page: Int(ent.page)))
                }
                try? self.ctx.save()
                promise(.success(saved))
            }
        }.eraseToAnyPublisher()
    }

    func fetchAll() -> AnyPublisher<[Match], Never> {
        let fetch: NSFetchRequest<MatchEntity> = MatchEntity.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return Future { [weak self] promise in
            guard let self = self else { return }
            self.ctx.perform {
                let ents = (try? self.ctx.fetch(fetch)) ?? []
                let models = ents.map { ent in
                    Match(id: ent.id,
                          firstName: ent.firstName ?? "",
                          lastName: ent.lastName ?? "",
                          age: Int(ent.age),
                          city: ent.city ?? "",
                          country: ent.country ?? "",
                          thumbnailURL: ent.thumbnailURL ?? "",
                          status: Match.MatchStatus(rawValue: ent.status ?? "none") ?? .none,
                          page: Int(ent.page))
                }
                promise(.success(models))
            }
        }.eraseToAnyPublisher()
    }

    func updateStatus(id: String, status: Match.MatchStatus) -> AnyPublisher<Match, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            self.ctx.perform {
                let fetch: NSFetchRequest<MatchEntity> = MatchEntity.fetchRequest()
                fetch.predicate = NSPredicate(format: "id == %@", id)
                guard let ent = (try? self.ctx.fetch(fetch))?.first else {
                    promise(.failure(NSError(domain: "notfound", code: 404)))
                    return
                }
                ent.status = status.rawValue
                ent.pendingSync = true
                try? self.ctx.save()
                let m = Match(id: ent.id,
                              firstName: ent.firstName ?? "",
                              lastName: ent.lastName ?? "",
                              age: Int(ent.age),
                              city: ent.city ?? "",
                              country: ent.country ?? "",
                              thumbnailURL: ent.thumbnailURL ?? "",
                              status: Match.MatchStatus(rawValue: ent.status ?? "none") ?? .none,
                              page: Int(ent.page))
                promise(.success(m))
            }
        }.eraseToAnyPublisher()
    }

    func fetchPendingSync() -> [Match] {
        let fetch: NSFetchRequest<MatchEntity> = MatchEntity.fetchRequest()
        fetch.predicate = NSPredicate(format: "pendingSync == YES")
        let ents = (try? ctx.fetch(fetch)) ?? []
        return ents.map { ent in
            Match(id: ent.id,
                  firstName: ent.firstName ?? "",
                  lastName: ent.lastName ?? "",
                  age: Int(ent.age),
                  city: ent.city ?? "",
                  country: ent.country ?? "",
                  thumbnailURL: ent.thumbnailURL ?? "",
                  status: Match.MatchStatus(rawValue: ent.status ?? "none") ?? .none,
                  page: Int(ent.page))
        }
    }
}
