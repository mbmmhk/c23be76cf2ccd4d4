//
//  MarketsPriceUseCaseTests.swift
//  CDC_InterviewTests
//
//  Created by Junjie Gu on 2025/8/14.
//

import XCTest
import RxSwift
import RxTest
@testable import CDC_Interview

final class MarketsPriceUseCaseTests: XCTestCase {

    // MARK: - Properties

    private var sut: MarketsPriceUseCase!
    private var mockRepository: MockMarketsRepository!
    private var disposeBag: DisposeBag!
    private var testScheduler: TestScheduler!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockRepository = MockMarketsRepository()
        sut = MarketsPriceUseCase(repository: mockRepository)
        disposeBag = DisposeBag()
        testScheduler = TestScheduler(initialClock: 0)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockRepository = nil
        disposeBag = nil
        testScheduler = nil
        try super.tearDownWithError()
    }

    // MARK: - async/await Tests

    func testFetchUSDPricesAsync_Success_ReturnsCorrectData() async throws {
        // Given
        let expectedPrices = createMockUSDPrices()
        mockRepository.mockUSDPricesResult = .success(expectedPrices)

        // When
        let result = try await sut.fetchUSDPricesAsync()

        // Then
        XCTAssertEqual(result.count, expectedPrices.count)
        XCTAssertEqual(result.first?.id, expectedPrices.first?.id)
        XCTAssertEqual(result.first?.name, expectedPrices.first?.name)
        XCTAssertEqual(result.first?.usd, expectedPrices.first?.usd)
        XCTAssertEqual(result.first?.tags, expectedPrices.first?.tags)
        XCTAssertEqual(mockRepository.fetchUSDPricesCallCount, 1)
    }

    func testFetchUSDPricesAsync_EmptyData_ReturnsEmptyArray() async throws {
        // Given
        mockRepository.mockUSDPricesResult = .success([])

        // When
        let result = try await sut.fetchUSDPricesAsync()

        // Then
        XCTAssertTrue(result.isEmpty)
        XCTAssertEqual(mockRepository.fetchUSDPricesCallCount, 1)
    }

    func testFetchUSDPricesAsync_RepositoryError_ThrowsError() async {
        // Given
        let expectedError = TestError.networkError
        mockRepository.mockUSDPricesResult = .failure(expectedError)

        // When & Then
        do {
            _ = try await sut.fetchUSDPricesAsync()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is TestError)
            XCTAssertEqual(error as? TestError, expectedError)
        }
        XCTAssertEqual(mockRepository.fetchUSDPricesCallCount, 1)
    }

    // MARK: - RxSwift Observable Tests

    func testFetchUSDPrices_Success_EmitsCorrectData() {
        // Given
        let expectedPrices = createMockUSDPrices()
        mockRepository.mockUSDPricesResult = .success(expectedPrices)

        var receivedResult: [USDPrice.Price]?
        var receivedError: Error?
        let expectation = XCTestExpectation(description: "Fetch items completes")

        // When
        sut.fetchUSDPrices()
            .subscribe(
                onNext: { result in
                    receivedResult = result
                },
                onError: { error in
                    receivedError = error
                    expectation.fulfill()
                },
                onCompleted: {
                    expectation.fulfill()
                }
            )
            .disposed(by: disposeBag)

        // Then
        wait(for: [expectation], timeout: 1.0)

        XCTAssertNil(receivedError)
        XCTAssertNotNil(receivedResult)
        XCTAssertEqual(receivedResult?.count, expectedPrices.count)
        XCTAssertEqual(receivedResult?.first?.id, expectedPrices.first?.id)
        XCTAssertEqual(receivedResult?.first?.name, expectedPrices.first?.name)
        XCTAssertEqual(receivedResult?.first?.usd, expectedPrices.first?.usd)
        XCTAssertEqual(receivedResult?.first?.tags, expectedPrices.first?.tags)
        XCTAssertEqual(mockRepository.fetchUSDPricesCallCount, 1)
    }

    func testFetchUSDPrices_EmptyData_EmitsEmptyArray() {
        // Given
        mockRepository.mockUSDPricesResult = .success([])

        var receivedResult: [USDPrice.Price]?
        var receivedError: Error?
        let expectation = XCTestExpectation(description: "Fetch items completes")

        // When
        sut.fetchUSDPrices()
            .subscribe(
                onNext: { result in
                    receivedResult = result
                },
                onError: { error in
                    receivedError = error
                    expectation.fulfill()
                },
                onCompleted: {
                    expectation.fulfill()
                }
            )
            .disposed(by: disposeBag)

        // Then
        wait(for: [expectation], timeout: 1.0)

        XCTAssertNil(receivedError)
        XCTAssertNotNil(receivedResult)
        XCTAssertTrue(receivedResult?.isEmpty ?? false)
        XCTAssertEqual(mockRepository.fetchUSDPricesCallCount, 1)
    }

    func testFetchUSDPrices_RepositoryError_EmitsError() {
        // Given
        let expectedError = TestError.networkError
        mockRepository.mockUSDPricesResult = .failure(expectedError)

        var receivedResult: [USDPrice.Price]?
        var receivedError: Error?
        let expectation = XCTestExpectation(description: "Fetch items completes")

        // When
        sut.fetchUSDPrices()
            .subscribe(
                onNext: { result in
                    receivedResult = result
                },
                onError: { error in
                    receivedError = error
                    expectation.fulfill()
                },
                onCompleted: {
                    expectation.fulfill()
                }
            )
            .disposed(by: disposeBag)

        // Then
        wait(for: [expectation], timeout: 1.0)

        XCTAssertNil(receivedResult)
        XCTAssertNotNil(receivedError)
        XCTAssertTrue(receivedError is TestError)
        XCTAssertEqual(receivedError as? TestError, expectedError)
        XCTAssertEqual(mockRepository.fetchUSDPricesCallCount, 1)
    }


}

// MARK: - Test Helper Classes

/// Mock repository for testing USDPriceUseCase
private class MockMarketsRepository: MarketsRepositoryProtocol {

    // MARK: - Mock Properties

    var mockUSDPricesResult: Result<[USDPrice.Price], Error> = .success([])
    var mockAllPricesResult: Result<[AllPrice.Price], Error> = .success([])

    // MARK: - Call Tracking

    private(set) var fetchUSDPricesCallCount = 0
    private(set) var fetchAllPricesCallCount = 0

    // MARK: - MarketsRepositoryProtocol Implementation

    func fetchUSDPrices() async throws -> [USDPrice.Price] {
        fetchUSDPricesCallCount += 1

        switch mockUSDPricesResult {
        case .success(let prices):
            return prices
        case .failure(let error):
            throw error
        }
    }

    func fetchAllPrices() async throws -> [AllPrice.Price] {
        fetchAllPricesCallCount += 1

        switch mockAllPricesResult {
        case .success(let prices):
            return prices
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Test Errors

/// Test-specific errors for mocking failure scenarios
private enum TestError: Error, Equatable {
    case networkError
    case parsingError
    case unknownError

    var localizedDescription: String {
        switch self {
        case .networkError:
            return "Network error occurred"
        case .parsingError:
            return "Data parsing error occurred"
        case .unknownError:
            return "Unknown error occurred"
        }
    }
}

// MARK: - Test Data Helpers

private extension MarketsPriceUseCaseTests {

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
            ),
            USDPrice.Price(
                id: 3,
                name: "Cardano",
                usd: Decimal(1.25),
                tags: [Tag.deposit, Tag.withdrawal]
            )
        ]
    }

    // MARK: - AllPrice Tests

    func testFetchAllPricesAsync_Success_ReturnsCorrectData() async throws {
        // Given
        let expectedPrices = createMockAllPrices()
        mockRepository.mockAllPricesResult = .success(expectedPrices)

        // When
        let result = try await sut.fetchAllPricesAsync()

        // Then
        XCTAssertEqual(result.count, expectedPrices.count)
        XCTAssertEqual(result.first?.price.usd, expectedPrices.first?.price.usd)
        XCTAssertEqual(result.first?.price.eur, expectedPrices.first?.price.eur)
        XCTAssertEqual(mockRepository.fetchAllPricesCallCount, 1)
    }

    func testFetchAllPrices_Success_EmitsCorrectData() {
        // Given
        let expectedPrices = createMockAllPrices()
        mockRepository.mockAllPricesResult = .success(expectedPrices)

        var receivedResult: [AllPrice.Price]?
        let expectation = XCTestExpectation(description: "Fetch all prices completes")

        // When
        sut.fetchAllPrices()
            .subscribe(
                onNext: { result in
                    receivedResult = result
                    expectation.fulfill()
                }
            )
            .disposed(by: disposeBag)

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedResult)
        XCTAssertEqual(receivedResult?.count, expectedPrices.count)
        XCTAssertEqual(receivedResult?.first?.price.usd, expectedPrices.first?.price.usd)
        XCTAssertEqual(receivedResult?.first?.price.eur, expectedPrices.first?.price.eur)
        XCTAssertEqual(mockRepository.fetchAllPricesCallCount, 1)
    }

    private func createMockAllPrices() -> [AllPrice.Price] {
        return [
            AllPrice.Price(
                id: 1,
                name: "Bitcoin",
                price: AllPrice.Price.PriceRecord(
                    usd: Decimal(50000.00),
                    eur: Decimal(42000.00)
                ),
                tags: [Tag.deposit]
            ),
            AllPrice.Price(
                id: 2,
                name: "Ethereum",
                price: AllPrice.Price.PriceRecord(
                    usd: Decimal(3200.75),
                    eur: Decimal(2700.50)
                ),
                tags: [Tag.withdrawal]
            )
        ]
    }
}
