import SwiftUI
import Foundation

struct MatchCardView: View {
    @ObservedObject var viewModel: MatchCardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: viewModel.match.thumbnailURL)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.match.firstName) \(viewModel.match.lastName)")
                        .font(.title3.bold())

                    Text("\(viewModel.match.age) yrs • \(viewModel.match.city), \(viewModel.match.country)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            
            Group {
                switch viewModel.match.status {
                case .none:
                    HStack(spacing: 12) {
                        Button {
                            viewModel.accept()
                        } label: {
                            Label("Accept", systemImage: "hand.thumbsup.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)

                        Button {
                            viewModel.decline()
                        } label: {
                            Label("Decline", systemImage: "hand.thumbsdown.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }

                case .accepted:
                    Label("Accepted", systemImage: "hand.thumbsup.fill")
                        .font(.headline)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.15))
                        .clipShape(Capsule())
                        .transition(.opacity.combined(with: .scale))

                case .declined:
                    Label("Declined", systemImage: "hand.thumbsdown.fill")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.15))
                        .clipShape(Capsule())
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.easeInOut, value: viewModel.match.status)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemBackground),
                    Color(UIColor.secondarySystemBackground)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }
}



