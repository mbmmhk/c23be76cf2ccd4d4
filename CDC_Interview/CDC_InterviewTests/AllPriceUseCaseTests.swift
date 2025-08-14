//
//  AllPriceUseCaseTests.swift
//  CDC_InterviewTests
//
//  Created by Junjie Gu on 2025/8/14.
//

import XCTest
import RxSwift
import RxTest
@testable import CDC_Interview

final class AllPriceUseCaseTests: XCTestCase {

    // MARK: - Properties

    private var sut: AllPriceUseCase!
    private var mockRepository: MockMarketsRepository!
    private var disposeBag: DisposeBag!
    private var testScheduler: TestScheduler!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockRepository = MockMarketsRepository()
        sut = AllPriceUseCase(repository: mockRepository)
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

    func testFetchItemsAsync_Success_ReturnsCorrectData() async throws {
        // Given
        let expectedPrices = createMockAllPrices()
        mockRepository.mockAllPricesResult = .success(expectedPrices)

        // When
        let result = try await sut.fetchItemsAsync()

        // Then
        XCTAssertEqual(result.count, expectedPrices.count)
        XCTAssertEqual(result.first?.id, expectedPrices.first?.id)
        XCTAssertEqual(result.first?.name, expectedPrices.first?.name)
        XCTAssertEqual(result.first?.price.usd, expectedPrices.first?.price.usd)
        XCTAssertEqual(result.first?.price.eur, expectedPrices.first?.price.eur)
        XCTAssertEqual(result.first?.tags, expectedPrices.first?.tags)
        XCTAssertEqual(mockRepository.fetchAllPricesCallCount, 1)
    }

    func testFetchItemsAsync_EmptyData_ReturnsEmptyArray() async throws {
        // Given
        mockRepository.mockAllPricesResult = .success([])

        // When
        let result = try await sut.fetchItemsAsync()

        // Then
        XCTAssertTrue(result.isEmpty)
        XCTAssertEqual(mockRepository.fetchAllPricesCallCount, 1)
    }

    func testFetchItemsAsync_RepositoryError_ThrowsError() async {
        // Given
        let expectedError = TestError.networkError
        mockRepository.mockAllPricesResult = .failure(expectedError)

        // When & Then
        do {
            _ = try await sut.fetchItemsAsync()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is TestError)
            XCTAssertEqual(error as? TestError, expectedError)
        }
        XCTAssertEqual(mockRepository.fetchAllPricesCallCount, 1)
    }

    // MARK: - RxSwift Observable Tests

    func testFetchItems_Success_EmitsCorrectData() {
        // Given
        let expectedPrices = createMockAllPrices()
        mockRepository.mockAllPricesResult = .success(expectedPrices)

        var receivedResult: [AllPrice.Price]?
        var receivedError: Error?
        let expectation = XCTestExpectation(description: "Fetch items completes")

        // When
        sut.fetchItems()
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
        XCTAssertEqual(receivedResult?.first?.price.usd, expectedPrices.first?.price.usd)
        XCTAssertEqual(receivedResult?.first?.price.eur, expectedPrices.first?.price.eur)
        XCTAssertEqual(receivedResult?.first?.tags, expectedPrices.first?.tags)
        XCTAssertEqual(mockRepository.fetchAllPricesCallCount, 1)
    }

    func testFetchItems_EmptyData_EmitsEmptyArray() {
        // Given
        mockRepository.mockAllPricesResult = .success([])

        var receivedResult: [AllPrice.Price]?
        var receivedError: Error?
        let expectation = XCTestExpectation(description: "Fetch items completes")

        // When
        sut.fetchItems()
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
        XCTAssertEqual(mockRepository.fetchAllPricesCallCount, 1)
    }

    func testFetchItems_RepositoryError_EmitsError() {
        // Given
        let expectedError = TestError.networkError
        mockRepository.mockAllPricesResult = .failure(expectedError)

        var receivedResult: [AllPrice.Price]?
        var receivedError: Error?
        let expectation = XCTestExpectation(description: "Fetch items completes")

        // When
        sut.fetchItems()
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
        XCTAssertEqual(mockRepository.fetchAllPricesCallCount, 1)
    }

    // MARK: - Singleton Tests

    func testSharedInstance_ReturnsSameInstance() {
        // Given & When
        let instance1 = AllPriceUseCase.shared
        let instance2 = AllPriceUseCase.shared

        // Then
        XCTAssertTrue(instance1 === instance2)
    }
}

// MARK: - Test Helper Classes

/// Mock repository for testing AllPriceUseCase
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

private extension AllPriceUseCaseTests {

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
            ),
            AllPrice.Price(
                id: 3,
                name: "Cardano",
                price: AllPrice.Price.PriceRecord(
                    usd: Decimal(1.25),
                    eur: Decimal(1.05)
                ),
                tags: [Tag.deposit, Tag.withdrawal]
            )
        ]
    }
}
