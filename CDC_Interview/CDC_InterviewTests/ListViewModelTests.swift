//
//  ListViewModelTests.swift
//  CDC_InterviewTests
//
//  Created by Junjie Gu on 2025/8/14.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import CDC_Interview

final class ListViewModelTests: XCTestCase {
    
    private var sut: CryptoListViewModel!
    private var mockPriceUseCase: MockMarketsPriceUseCase!
    private var mockFeatureFlagProvider: MockFeatureFlagProvider!
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        mockPriceUseCase = MockMarketsPriceUseCase()
        mockFeatureFlagProvider = MockFeatureFlagProvider()
        
        let testDependency = Dependency()
        testDependency.register(MarketsPriceUseCaseProtocol.self) { _ in
            return self.mockPriceUseCase
        }
        testDependency.register(FeatureFlagProviderProtocol.self) { _ in
            return self.mockFeatureFlagProvider
        }

        sut = CryptoListViewModel(dependencyProvider: testDependency)
    }
    
    override func tearDown() {
        sut = nil
        mockPriceUseCase = nil
        mockFeatureFlagProvider = nil
        scheduler = nil
        disposeBag = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    private func createMockUSDPrices() -> [USDPrice.Price] {
        return [
            USDPrice.Price(
                id: 1,
                name: "Bitcoin",
                usd: Decimal(50000.00),
                tags: [Tag.deposit]
            ),
            USDPrice.Price(
                id: 2,
                name: "Ethereum",
                usd: Decimal(3200.75),
                tags: [Tag.withdrawal]
            )
        ]
    }
}

// MARK: - Mock Classes
private class MockMarketsPriceUseCase: MarketsPriceUseCaseProtocol {
    var mockUSDPricesResult: Result<[USDPrice.Price], Error> = .success([])
    var mockAllPricesResult: Result<[AllPrice.Price], Error> = .success([])
    
    private(set) var fetchUSDPricesCallCount = 0
    private(set) var fetchAllPricesCallCount = 0
    
    func fetchUSDPrices() -> Observable<[USDPrice.Price]> {
        fetchUSDPricesCallCount += 1
        switch mockUSDPricesResult {
        case .success(let prices):
            return .just(prices)
        case .failure(let error):
            return .error(error)
        }
    }
    
    func fetchAllPrices() -> Observable<[AllPrice.Price]> {
        fetchAllPricesCallCount += 1
        switch mockAllPricesResult {
        case .success(let prices):
            return .just(prices)
        case .failure(let error):
            return .error(error)
        }
    }
    
    func fetchUSDPricesAsync() async throws -> [USDPrice.Price] {
        fetchUSDPricesCallCount += 1
        switch mockUSDPricesResult {
        case .success(let prices):
            return prices
        case .failure(let error):
            throw error
        }
    }
    
    func fetchAllPricesAsync() async throws -> [AllPrice.Price] {
        fetchAllPricesCallCount += 1
        switch mockAllPricesResult {
        case .success(let prices):
            return prices
        case .failure(let error):
            throw error
        }
    }
}

private class MockFeatureFlagProvider: FeatureFlagProviderProtocol {
    var mockEURSupportEnabled: Bool = false

    func observeFlagValue(flag: FeatureFlagType) -> Observable<Bool> {
        return .just(mockEURSupportEnabled)
    }

    func getValue(flag: FeatureFlagType) -> Bool {
        return mockEURSupportEnabled
    }

    func update(flag: FeatureFlagType, newValue: Bool) {
        if flag == .supportEUR {
            mockEURSupportEnabled = newValue
        }
    }
}
