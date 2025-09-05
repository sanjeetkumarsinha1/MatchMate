import SwiftUI

struct MatchListView: View {
    @StateObject var vm = MatchListViewModel()

    var body: some View {
        NavigationView {
            Group {
                if vm.matches.isEmpty {
                    if vm.isLoadingPage {
                        ProgressView("Loading...")
                    } else {
                        Text("No matches. Pull to fetch or toggle online.")
                    }
                } else {
                    List {
                        ForEach(vm.matches) { match in
                            MatchCardView(viewModel: MatchCardViewModel(match: match))
                                .onAppear {
                                    vm.loadNextPageIfNeeded(currentItem: match)
                                }
                        }
                        if vm.isLoadingPage {
                            HStack { Spacer(); ProgressView(); Spacer() }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        vm.fetchNextPageInitial()
                    }
                }
            }
            .navigationTitle("MatchMate")
            .onAppear {
                vm.fetchNextPageInitial()
            }
            .alert(item: Binding(get: { vm.errorMessage.map { ErrorWrapper(message: $0) } }, set: { _ in vm.errorMessage = nil })) { wrapper in
                Alert(title: Text("Error"), message: Text(wrapper.message), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}
