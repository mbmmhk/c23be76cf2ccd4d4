import SwiftUI

struct CryptoListView: View {
    @StateObject private var viewModel = CryptoListViewModel()

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search for a token", text: $viewModel.searchText)
                    .padding(8)

                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.items) { item in
                        CryptoListItemView(displayItem: item)
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
}

#Preview {
    CryptoListView()
}
