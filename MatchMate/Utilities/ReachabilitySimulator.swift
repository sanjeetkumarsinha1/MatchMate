import Foundation
import Combine

final class ReachabilitySimulator {
    static let shared = ReachabilitySimulator()
    @Published var isOnline: Bool = true
    private init() {}
    func toggleOnline() { isOnline.toggle() }
}
