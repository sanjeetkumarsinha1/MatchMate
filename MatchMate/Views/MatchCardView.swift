import SwiftUI
import Foundation

struct MatchCardView: View {
    @ObservedObject var viewModel: MatchCardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AsyncImage(url: URL(string: viewModel.match.thumbnailURL)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading) {
                    Text("\(viewModel.match.firstName) \(viewModel.match.lastName)")
                        .font(.headline)
                    Text("\(viewModel.match.age) yrs, \(viewModel.match.city), \(viewModel.match.country)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            if viewModel.match.status == .none {
                HStack {
                    Button(action: { viewModel.accept() }) {
                        Text("Accept")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                    Button(action: { viewModel.decline() }) {
                        Text("Decline")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            } else {
                Text(viewModel.match.status == .accepted ? "Accepted" : "Declined")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        viewModel.match.status == .accepted
                        ? Color.green.opacity(0.2)
                        : Color.red.opacity(0.2)
                    )
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}


