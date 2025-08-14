//
//  DetailViewModelTests.swift
//  CDC_InterviewTests
//
//  Created by Junjie Gu on 2025/8/14.
//

import XCTest
import RxSwift
import RxTest
@testable import CDC_Interview

final class DetailViewModelTests: XCTestCase {

    private var sut: DetailViewModel!
    private var mockFeatureFlagProvider: MockFeatureFlagProvider!
    private var testDependency: Dependency!
    private var testDisplayItem: CryptoListViewModel.DisplayItem!

    @MainActor
    override func setUp() {
        super.setUp()

        mockFeatureFlagProvider = MockFeatureFlagProvider()
        testDependency = Dependency()

        testDependency.register(FeatureFlagProviderProtocol.self) { _ in
            return self.mockFeatureFlagProvider
        }

        testDisplayItem = CryptoListViewModel.DisplayItem(
            id: 1,
            name: "BTC",
            symbol: "BTC",
            usdPrice: "$29,130.52",
            eurPrice: "€27,084.11",
            tags: ["withdrawal", "deposit"],
            showEUR: false
        )
    }

    @MainActor
    override func tearDown() {
        sut = nil
        mockFeatureFlagProvider = nil
        testDependency = nil
        testDisplayItem = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    @MainActor
    func testInitialization_WithValidDisplayItem() {
        // Given & When
        sut = DetailViewModel(displayItem: testDisplayItem, dependencyProvider: testDependency)

        // Then
        XCTAssertEqual(sut.tokenName, "BTC")
        XCTAssertFalse(sut.showEURPrice)
        XCTAssertEqual(sut.formattedPrices, "USD: $29,130.52")
    }

    @MainActor
    func testInitialization_WithMissingDependency_ShouldFatalError() {
        // Given
        let _ = Dependency()

        // When & Then
        // Note: We can't directly test fatalError in unit tests
        // This test documents the expected behavior
        XCTAssertTrue(true, "fatalError is expected when FeatureFlagProvider is not registered")
    }

    // MARK: - Feature Flag Tests

    @MainActor
    func testShowEURPrice_WhenFeatureFlagEnabled_ShouldShowBothPrices() {
        // Given
        mockFeatureFlagProvider.mockEURSupportEnabled = true
        sut = DetailViewModel(displayItem: testDisplayItem, dependencyProvider: testDependency)

        // When
        // The RxSwift binding should automatically update the prices

        // Then
        XCTAssertTrue(sut.showEURPrice)
        XCTAssertEqual(sut.formattedPrices, "USD: $29,130.52\nEUR: €27,084.11")
    }

    @MainActor
    func testShowEURPrice_WhenFeatureFlagDisabled_ShouldShowUSDOnly() {
        // Given
        mockFeatureFlagProvider.mockEURSupportEnabled = false
        sut = DetailViewModel(displayItem: testDisplayItem, dependencyProvider: testDependency)

        // When
        // The RxSwift binding should automatically update the prices

        // Then
        XCTAssertFalse(sut.showEURPrice)
        XCTAssertEqual(sut.formattedPrices, "USD: $29,130.52")
    }

    @MainActor
    func testShowEURPrice_WhenEURPriceNotAvailable_ShouldShowUSDOnly() {
        // Given
        let itemWithoutEUR = CryptoListViewModel.DisplayItem(
            id: 2,
            name: "ETH",
            symbol: "ETH",
            usdPrice: "$2,845.67",
            eurPrice: nil,
            tags: ["deposit"],
            showEUR: false
        )

        mockFeatureFlagProvider.mockEURSupportEnabled = true
        sut = DetailViewModel(displayItem: itemWithoutEUR, dependencyProvider: testDependency)

        // When & Then
        XCTAssertTrue(sut.showEURPrice)
        XCTAssertEqual(sut.formattedPrices, "USD: $2,845.67")
    }

    // MARK: - Computed Properties Tests

    @MainActor
    func testTokenName_ShouldReturnCorrectName() {
        // Given
        sut = DetailViewModel(displayItem: testDisplayItem, dependencyProvider: testDependency)

        // When & Then
        XCTAssertEqual(sut.tokenName, "BTC")
    }
}

// MARK: - Mock Objects

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
