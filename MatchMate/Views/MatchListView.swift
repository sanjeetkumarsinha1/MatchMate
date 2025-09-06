import SwiftUI

struct MatchListView: View {
    @StateObject var vm = MatchListViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.7),
                        Color.blue.opacity(0.7),
                        Color.pink.opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

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
    }

    @ViewBuilder
    private var content: some View {
        if vm.cardViewModels.isEmpty {
            if vm.isLoadingPage {
                ProgressView("Loading...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Text("No matches. Pull to fetch or toggle online.")
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
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
                    .listRowBackground(Color.clear)
            }
            if vm.isLoadingPage {
                HStack { Spacer(); ProgressView(); Spacer() }
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            vm.fetchNextPageInitial()
        }
        .scrollContentBackground(.hidden)
    }
}

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}
