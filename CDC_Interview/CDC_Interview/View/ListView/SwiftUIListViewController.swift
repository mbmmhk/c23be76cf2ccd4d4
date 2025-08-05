import SwiftUI
import Combine

struct CryptoListView: View {
    @StateObject private var viewModel = ListViewModel()

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search for a token", text: $viewModel.searchText)
                    .padding(8)
                List(viewModel.displayItems) { priceItem in
                    ItemView(usdPrice: priceItem)
                }
            }
            .task {
                await viewModel.fetchItems()
            }
        }
    }
}

struct ItemView: View {
    private let formatter = CryptoFormatter.shared
    let usdPrice: USDPrice.Price

    var body: some View {
        VStack(alignment: .leading) {
            Text(usdPrice.name)
                .font(.headline)
            Text("Price: \(formatter.format(value: usdPrice.usd))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

@MainActor
class ListViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var displayItems: [USDPrice.Price] = []

    private let dependency: Dependency = .shared
    private let useCase: USDPriceUseCase = .shared
    private let featureFlagProvider: FeatureFlagProvider

    init() {
        self.featureFlagProvider = dependency.resolve(FeatureFlagProvider.self)!
    }

    func fetchItems() async {
        let items = try? await useCase.fetchItemsAsync()
        displayItems = items ?? []
    }
}

#Preview {
    CryptoListView()
}
