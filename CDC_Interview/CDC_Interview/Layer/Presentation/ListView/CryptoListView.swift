import SwiftUI

struct CryptoListView: View {
    @StateObject private var viewModel = CryptoListViewModel()
    weak var coordinator: CryptoListCoordinatorProtocol?

    var body: some View {
        VStack {
            TextField("Search for a token", text: $viewModel.searchText)
                .padding(8)

            if viewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.items) { item in
                    CryptoListItemView(displayItem: item)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            coordinator?.showDetail(for: item)
                        }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}

#Preview {
    CryptoListView()
}
