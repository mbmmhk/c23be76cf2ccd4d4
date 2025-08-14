
import Foundation
import RxSwift
import RxCocoa

/// Protocol defining price use case operations for cryptocurrency market data
/// Provides both reactive (Observable) and async/await interfaces for fetching price information
protocol MarketsPriceUseCaseProtocol {

    /// Fetches USD prices for cryptocurrencies using reactive programming
    /// - Returns: Observable that emits an array of USD price data
    func fetchUSDPrices() -> Observable<[USDPrice.Price]>

    /// Fetches all currency prices (USD, EUR, etc.) for cryptocurrencies using reactive programming
    /// - Returns: Observable that emits an array of multi-currency price data
    func fetchAllPrices() -> Observable<[AllPrice.Price]>

    /// Fetches USD prices for cryptocurrencies using async/await
    /// - Returns: Array of USD price data
    /// - Throws: Repository or network related errors
    func fetchUSDPricesAsync() async throws -> [USDPrice.Price]

    /// Fetches all currency prices (USD, EUR, etc.) for cryptocurrencies using async/await
    /// - Returns: Array of multi-currency price data
    /// - Throws: Repository or network related errors
    func fetchAllPricesAsync() async throws -> [AllPrice.Price]
}

/// Unified use case for handling both USD and All price operations
class MarketsPriceUseCase: MarketsPriceUseCaseProtocol {

    private let disposeBag = DisposeBag()
    private let repository: MarketsRepositoryProtocol

    init(repository: MarketsRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - USD Price Operations
    func fetchUSDPrices() -> Observable<[USDPrice.Price]> {
        return repository.asSingle { try await self.repository.fetchUSDPrices() }
            .asObservable()
    }

    func fetchUSDPricesAsync() async throws -> [USDPrice.Price] {
        return try await repository.fetchUSDPrices()
    }

    // MARK: - All Price Operations
    func fetchAllPrices() -> Observable<[AllPrice.Price]> {
        return repository.asSingle { try await self.repository.fetchAllPrices() }
            .asObservable()
    }

    func fetchAllPricesAsync() async throws -> [AllPrice.Price] {
        return try await repository.fetchAllPrices()
    }
}
