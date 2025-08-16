//
//  CryptoListViewModel.swift
//  CDC_Interview
//
//  Created by Junjie Gu on 2025/8/14.
//

import Foundation
import SwiftUI
import RxSwift
import RxCocoa

/// ViewModel for managing cryptocurrency list display logic
/// Follows RxSwift best practices with Driver pattern for UI binding
/// Simplified to work directly with SwiftUI without wrapper
@MainActor
final class CryptoListViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var items: [DisplayItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var searchText: String = "" {
        didSet { searchTextRelay.accept(searchText) }
    }

    @Published var showEURPrice: Bool = false

    // MARK: - Dependencies
    private let priceUseCase: MarketsPriceUseCaseProtocol
    private let featureFlagProvider: FeatureFlagProviderProtocol
    private let disposeBag = DisposeBag()

    // MARK: - RxSwift Internal State
    private let searchTextRelay = BehaviorRelay<String>(value: "")

    // MARK: - Private State for filtering
    private var allItems: [DisplayItem] = []

    // MARK: - Initialization
    init(dependencyProvider: Dependency = Dependency.shared) {
        guard let priceUseCase = dependencyProvider.resolve(MarketsPriceUseCaseProtocol.self) else {
            fatalError("MarketsPriceUseCaseProtocol is not registered in dependency container")
        }

        guard let featureFlagProvider = dependencyProvider.resolve(FeatureFlagProviderProtocol.self) else {
            fatalError("FeatureFlagProviderProtocol is not registered in dependency container")
        }

        self.priceUseCase = priceUseCase
        self.featureFlagProvider = featureFlagProvider

        setupRxBindings()
    }

    // MARK: - RxSwift Setup
    private func setupRxBindings() {
        let showEURDriver = featureFlagProvider.observeFlagValue(flag: .supportEUR)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        let loadingResult = showEURDriver
            .flatMapLatest { [weak self] showEUR -> Driver<LoadingState> in
                guard let self = self else { return .empty() }

                let fetchObservable = showEUR ?
                    self.priceUseCase.fetchAllPrices().map { self.convertAllPricesToDisplayItems($0) } :
                    self.priceUseCase.fetchUSDPrices().map { self.convertUSDPricesToDisplayItems($0) }

                return fetchObservable
                    .map { LoadingState.success($0) }
                    .catch { error in .just(LoadingState.error(error.localizedDescription)) }
                    .startWith(LoadingState.loading)
                    .asDriver(onErrorJustReturn: LoadingState.error("Unknown error"))
            }

        loadingResult
            .drive(onNext: { [weak self] state in
                switch state {
                case .loading:
                    self?.isLoading = true
                    self?.errorMessage = nil

                case .success(let items):
                    self?.updateItems(items)
                    self?.isLoading = false
                    self?.errorMessage = nil

                case .error(let message):
                    self?.isLoading = false
                    self?.errorMessage = message
                }
            })
            .disposed(by: disposeBag)

        showEURDriver
            .drive(onNext: { [weak self] showEUR in
                self?.showEURPrice = showEUR
            })
            .disposed(by: disposeBag)

        searchTextRelay
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.filterCurrentItems()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Private Methods
    private func updateItems(_ newItems: [DisplayItem]) {
        allItems = newItems
        filterCurrentItems()
    }

    private func filterCurrentItems() {
        if searchText.isEmpty {
            items = allItems
        } else {
            let lowercasedSearch = searchText.lowercased()
            items = allItems.filter { item in
                item.name.lowercased().contains(lowercasedSearch) ||
                item.symbol.lowercased().contains(lowercasedSearch) ||
                item.tags.contains { $0.lowercased().contains(lowercasedSearch) }
            }
        }
    }

    // MARK: - Data Conversion Methods
    private func convertUSDPricesToDisplayItems(_ prices: [USDPrice.Price]) -> [DisplayItem] {
        return prices.map { price in
            createDisplayItem(
                id: price.id,
                name: price.name,
                tags: price.tags.map { $0.rawValue },
                usdPrice: price.usd,
                eurPrice: nil as Decimal?,
                showEUR: false
            )
        }
    }

    private func convertAllPricesToDisplayItems(_ prices: [AllPrice.Price]) -> [DisplayItem] {
        return prices.map { price in
            createDisplayItem(
                id: price.id,
                name: price.name,
                tags: price.tags.map { $0.rawValue },
                usdPrice: price.price.usd,
                eurPrice: price.price.eur,
                showEUR: true
            )
        }
    }

    // MARK: - Helper Methods
    private func createDisplayItem(
        id: Int,
        name: String,
        tags: [String],
        usdPrice: Decimal,
        eurPrice: Decimal?,
        showEUR: Bool
    ) -> DisplayItem {
        let sortedTags = tags
            .sorted { tag1, tag2 in
                tag1.localizedCaseInsensitiveCompare(tag2) == .orderedAscending
            }

        return DisplayItem(
            id: id,
            name: name,
            symbol: extractSymbol(from: name),
            usdPrice: CryptoFormatter.shared.formatUSD(usdPrice),
            eurPrice: eurPrice.map { CryptoFormatter.shared.formatEUR($0) },
            tags: sortedTags,
            showEUR: showEUR
        )
    }

    private func extractSymbol(from name: String) -> String {
        // Simple symbol extraction logic, may need more complex logic in real projects
        return String(name.prefix(3)).uppercased()
    }
}

// MARK: - Supporting Types
extension CryptoListViewModel {

    enum LoadingState {
        case loading
        case success([DisplayItem])
        case error(String)
    }

    struct DisplayItem: Identifiable, Equatable {
        let id: Int
        let name: String
        let symbol: String
        let usdPrice: String
        let eurPrice: String?
        let tags: [String]
        let showEUR: Bool

        static func == (lhs: DisplayItem, rhs: DisplayItem) -> Bool {
            lhs.id == rhs.id
        }
    }
}
