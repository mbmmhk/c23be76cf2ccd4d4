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
    private let priceUseCase: MarketsPriceUseCaseProtocol
    private let featureFlagProvider: FeatureFlagProviderProtocol

    init() {
        self.priceUseCase = dependency.resolve(MarketsPriceUseCaseProtocol.self)!
        self.featureFlagProvider = dependency.resolve(FeatureFlagProviderProtocol.self)!
    }

    func fetchItems() async {
        let items = try? await priceUseCase.fetchUSDPricesAsync()
        displayItems = items ?? []
    }
}

#Preview {
    CryptoListView()
}
