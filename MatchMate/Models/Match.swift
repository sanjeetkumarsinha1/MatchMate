import Foundation

struct Match: Identifiable, Equatable {
    let id: String
    let firstName: String
    let lastName: String
    let age: Int
    let city: String
    let country: String
    let thumbnailURL: String
    var status: MatchStatus
    var page: Int

    enum MatchStatus: String {
        case none, accepted, declined
    }
}
