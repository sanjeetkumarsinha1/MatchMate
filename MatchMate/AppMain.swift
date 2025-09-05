import SwiftUI

@main
struct MatchMateApp: App {
    init() {
        // Initialize SyncManager
        _ = SyncManager.shared
    }

    var body: some Scene {
        WindowGroup {
            MatchListView()
        }
    }
}
