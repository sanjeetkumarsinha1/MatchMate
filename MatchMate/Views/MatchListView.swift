import SwiftUI

struct MatchListView: View {
    @StateObject var vm = MatchListViewModel()

    var body: some View {
        NavigationView {
            content
                .navigationTitle("MatchMate")
                .onAppear {
                    vm.fetchNextPageInitial()
                }
                .alert(item: Binding(
                    get: { vm.errorMessage.map { ErrorWrapper(message: $0) } },
                    set: { _ in vm.errorMessage = nil })
                ) { wrapper in
                    Alert(title: Text("Error"),
                          message: Text(wrapper.message),
                          dismissButton: .default(Text("OK")))
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if vm.cardViewModels.isEmpty {
            if vm.isLoadingPage {
                ProgressView("Loading...")
            } else {
                Text("No matches. Pull to fetch or toggle online.")
            }
        } else {
            matchList
        }
    }

    private var matchList: some View {
        List {
            ForEach(vm.cardViewModels) { cardVM in
                MatchCardView(viewModel: cardVM)
                    .onAppear {
                        vm.loadNextPageIfNeeded(currentItem: cardVM.match)
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

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}
