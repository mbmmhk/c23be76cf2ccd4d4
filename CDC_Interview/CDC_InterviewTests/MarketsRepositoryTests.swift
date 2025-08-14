//
//  MarketsRepositoryTests.swift
//  CDC_InterviewTests
//
//  Created by Junjie Gu on 2025/8/14.
//

import XCTest
import RxSwift
@testable import CDC_Interview

final class MarketsRepositoryTests: XCTestCase {

    // MARK: - Properties

    private var sut: MarketsRepository!
    private var mockDataSource: MockDataSource!
    private var disposeBag: DisposeBag!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDataSource = MockDataSource()
        sut = MarketsRepositoryWithMockDataSource(mockDataSource: mockDataSource)
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        sut = nil
        mockDataSource = nil
        disposeBag = nil
        try super.tearDownWithError()
    }

    // MARK: - async/await Tests

    func testFetchUSDPrices_Success_ReturnsCorrectData() async throws {
        // Given
        let expectedPrices = createMockUSDPrices()
        let mockUSDPrice = USDPrice(data: expectedPrices)
        mockDataSource.mockResult = .success(mockUSDPrice)

        // When
        let result = try await sut.fetchUSDPrices()

        // Then
        XCTAssertEqual(result.count, expectedPrices.count)
        XCTAssertEqual(result.first?.id, expectedPrices.first?.id)
        XCTAssertEqual(result.first?.name, expectedPrices.first?.name)
        XCTAssertEqual(mockDataSource.lastRequestedResource, .usdPrices)
    }

    func testFetchAllPrices_Success_ReturnsCorrectData() async throws {
        // Given
        let expectedPrices = createMockAllPrices()
        let mockAllPrice = AllPrice(data: expectedPrices)
        mockDataSource.mockResult = .success(mockAllPrice)

        // When
        let result = try await sut.fetchAllPrices()

        // Then
        XCTAssertEqual(result.count, expectedPrices.count)
        XCTAssertEqual(result.first?.id, expectedPrices.first?.id)
        XCTAssertEqual(result.first?.name, expectedPrices.first?.name)
        XCTAssertEqual(mockDataSource.lastRequestedResource, .allPrices)
    }

    func testFetchUSDPrices_DataSourceError_ThrowsError() async {
        // Given
        let expectedError = LocalDataFetchError.missingFile("test.json")
        mockDataSource.mockResult = .failure(expectedError)

        // When & Then
        do {
            _ = try await sut.fetchUSDPrices()
            XCTFail("Should throw error")
        } catch let error as LocalDataFetchError {
            XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchAllPrices_DataSourceError_ThrowsError() async {
        // Given
        let expectedError = LocalDataFetchError.invalidData(NSError(domain: "test", code: 1))
        mockDataSource.mockResult = .failure(expectedError)

        // When & Then
        do {
            _ = try await sut.fetchAllPrices()
            XCTFail("Should throw error")
        } catch let error as LocalDataFetchError {
            // Expected error
            XCTAssertTrue(error.localizedDescription.contains("Invalid data format"))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - RxSwift Generic Method Tests

    func testAsSingle_FetchUSDPrices_Success_ReturnsCorrectData() {
        // Given
        let expectedPrices = createMockUSDPrices()
        let mockUSDPrice = USDPrice(data: expectedPrices)
        mockDataSource.mockResult = .success(mockUSDPrice)
        let expectation = XCTestExpectation(description: "Should return USD prices")

        // When
        sut.asSingle { try await self.sut.fetchUSDPrices() }
            .subscribe(
                onSuccess: { prices in
                    // Then
                    XCTAssertEqual(prices.count, expectedPrices.count)
                    XCTAssertEqual(prices.first?.id, expectedPrices.first?.id)
                    XCTAssertEqual(self.mockDataSource.lastRequestedResource, .usdPrices)
                    expectation.fulfill()
                },
                onFailure: { error in
                    XCTFail("Should not fail: \(error)")
                }
            )
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 5.0)
    }

    func testAsSingle_FetchAllPrices_Success_ReturnsCorrectData() {
        // Given
        let expectedPrices = createMockAllPrices()
        let mockAllPrice = AllPrice(data: expectedPrices)
        mockDataSource.mockResult = .success(mockAllPrice)
        let expectation = XCTestExpectation(description: "Should return all prices")

        // When
        sut.asSingle { try await self.sut.fetchAllPrices() }
            .subscribe(
                onSuccess: { prices in
                    // Then
                    XCTAssertEqual(prices.count, expectedPrices.count)
                    XCTAssertEqual(prices.first?.id, expectedPrices.first?.id)
                    XCTAssertEqual(self.mockDataSource.lastRequestedResource, .allPrices)
                    expectation.fulfill()
                },
                onFailure: { error in
                    XCTFail("Should not fail: \(error)")
                }
            )
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 5.0)
    }

    func testAsSingle_DataSourceError_ReturnsError() {
        // Given
        let expectedError = LocalDataFetchError.missingFile("test.json")
        mockDataSource.mockResult = .failure(expectedError)
        let expectation = XCTestExpectation(description: "Should receive error")

        // When
        sut.asSingle { try await self.sut.fetchUSDPrices() }
            .subscribe(
                onSuccess: { _ in
                    XCTFail("Should not succeed")
                },
                onFailure: { error in
                    // Then
                    XCTAssertTrue(error is LocalDataFetchError)
                    expectation.fulfill()
                }
            )
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Thread Safety Tests

    func testAsSingle_CompletesOnMainThread() {
        // Given
        let expectedPrices = createMockUSDPrices()
        let mockUSDPrice = USDPrice(data: expectedPrices)
        mockDataSource.mockResult = .success(mockUSDPrice)
        let expectation = XCTestExpectation(description: "Should complete on main thread")

        // When
        sut.asSingle { try await self.sut.fetchUSDPrices() }
            .subscribe(
                onSuccess: { _ in
                    // Then
                    XCTAssertTrue(Thread.isMainThread, "Should complete on main thread")
                    expectation.fulfill()
                },
                onFailure: { error in
                    XCTFail("Should not fail: \(error)")
                }
            )
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Repository Error Tests

    func testAsSingle_RepositoryDeallocated_ThrowsRepositoryError() {
        // Given
        let expectation = XCTestExpectation(description: "Should receive repository error")

        // When
        let single = sut.asSingle { try await self.sut.fetchUSDPrices() }
        sut = nil  // Deallocate repository

        single.subscribe(
                onSuccess: { _ in
                    XCTFail("Should not succeed")
                },
                onFailure: { error in
                    // Then
                    XCTAssertTrue(error is RepositoryError)
                    if case RepositoryError.instanceDeallocated = error {
                        expectation.fulfill()
                    } else {
                        XCTFail("Wrong repository error type")
                    }
                }
            )
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Data Source Integration Tests

    func testMarketsRepository_WithLocalNetworkProvider_UsesLocalProvider() async throws {
        // Given
        let repository = MarketsRepository(networkProvider: .local)

        // When
        let result = try await repository.fetchUSDPrices()

        // Then
        XCTAssertFalse(result.isEmpty, "Should return data from local provider")
        // Verify it's actually using LocalDataSourceProvider by checking the data structure
        XCTAssertTrue(result.allSatisfy { $0.id > 0 }, "Local data should have valid IDs")
    }

    func testMarketsRepository_WithRemoteNetworkProvider_UsesRemoteProvider() async {
        // Given
        let repository = MarketsRepository(networkProvider: .remote(baseURL: "https://test-api.com"))

        // When & Then
        do {
            _ = try await repository.fetchUSDPrices()
            XCTFail("Should throw notImplemented error from RemoteDataSourceProvider")
        } catch RemoteDataFetchError.notImplemented {
            // Expected: RemoteDataSourceProvider should throw notImplemented
            XCTAssertTrue(true, "Correctly using RemoteDataSourceProvider")
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testMarketsRepository_WithRemoteNetworkProvider_RxSwift_UsesRemoteProvider() {
        // Given
        let repository = MarketsRepository(networkProvider: .remote(baseURL: "https://test-api.com"))
        let expectation = XCTestExpectation(description: "Should receive remote error")

        // When
        repository.asSingle { try await repository.fetchUSDPrices() }
            .subscribe(
                onSuccess: { _ in
                    XCTFail("Should not succeed with RemoteDataSourceProvider")
                },
                onFailure: { error in
                    // Then
                    if error is RemoteDataFetchError {
                        XCTAssertTrue(true, "Correctly using RemoteDataSourceProvider")
                        expectation.fulfill()
                    } else {
                        XCTFail("Should receive RemoteDataFetchError, got: \(error)")
                    }
                }
            )
            .disposed(by: disposeBag)

        wait(for: [expectation], timeout: 5.0)
    }



    // MARK: - NetworkProviderType Tests

    func testMarketsRepository_DefaultNetworkProvider_UsesLocal() async throws {
        // Given
        let repository = MarketsRepository() // Uses default .local

        // When
        let result = try await repository.fetchUSDPrices()

        // Then
        XCTAssertFalse(result.isEmpty, "Should return data from local provider")
    }

    func testMarketsRepository_ExplicitLocalNetworkProvider_UsesLocal() async throws {
        // Given
        let repository = MarketsRepository(networkProvider: .local)

        // When
        let result = try await repository.fetchUSDPrices()

        // Then
        XCTAssertFalse(result.isEmpty, "Should return data from local provider")
    }

    func testNetworkProviderType_DefaultRemote_HasCorrectBaseURL() {
        // Given & When
        let defaultRemote = NetworkProviderType.defaultRemote

        // Then
        if case .remote(let baseURL) = defaultRemote {
            XCTAssertEqual(baseURL, "https://api.crypto.com")
        } else {
            XCTFail("defaultRemote should be a remote type")
        }
    }

    func testNetworkProviderType_Description_ReturnsCorrectValues() {
        // Given
        let local = NetworkProviderType.local
        let remote = NetworkProviderType.remote(baseURL: "https://test.com")

        // When & Then
        XCTAssertEqual(local.description, "Local Data Source")
        XCTAssertEqual(remote.description, "Remote Data Source (https://test.com)")
    }
}

// MARK: - Test Helper Classes

/// Test-specific MarketsRepository that accepts a mock data source
private class MarketsRepositoryWithMockDataSource: MarketsRepository {
    private let mockDataSource: DataSourceProtocol

    init(mockDataSource: DataSourceProtocol) {
        self.mockDataSource = mockDataSource
        super.init(networkProvider: .local)
    }

    override func fetchUSDPrices() async throws -> [USDPrice.Price] {
        let usdPrice: USDPrice = try await mockDataSource.fetchData(forDataType: .usdPrices)
        return usdPrice.data
    }

    override func fetchAllPrices() async throws -> [AllPrice.Price] {
        let allPrice: AllPrice = try await mockDataSource.fetchData(forDataType: .allPrices)
        return allPrice.data
    }
}

// MARK: - Mock Data Source

private class MockDataSource: DataSourceProtocol {
    var mockResult: Result<Any, Error>?
    var lastRequestedResource: DataSourceResource?

    func fetchData<T: Decodable>(forDataType dataType: DataSourceResource) async throws -> T {
        lastRequestedResource = dataType

        guard let result = mockResult else {
            throw LocalDataFetchError.internalError(NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No mock result set"]))
        }

        switch result {
        case .success(let data):
            guard let typedData = data as? T else {
                throw LocalDataFetchError.invalidData(NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Type mismatch"]))
            }
            return typedData
        case .failure(let error):
            throw error
        }
    }


}

// MARK: - Test Data Helpers

private extension MarketsRepositoryTests {

    func createMockUSDPrices() -> [USDPrice.Price] {
        return [
            USDPrice.Price(
                id: 1,
                name: "Bitcoin",
                usd: Decimal(45000.50),
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

    func createMockAllPrices() -> [AllPrice.Price] {
        return [
            AllPrice.Price(
                id: 1,
                name: "Bitcoin",
                price: AllPrice.Price.PriceRecord(
                    usd: Decimal(45000.50),
                    eur: Decimal(38000.25)
                ),
                tags: [Tag.deposit]
            ),
            AllPrice.Price(
                id: 2,
                name: "Ethereum",
                price: AllPrice.Price.PriceRecord(
                    usd: Decimal(3200.75),
                    eur: Decimal(2700.60)
                ),
                tags: [Tag.withdrawal]
            )
        ]
    }
}
