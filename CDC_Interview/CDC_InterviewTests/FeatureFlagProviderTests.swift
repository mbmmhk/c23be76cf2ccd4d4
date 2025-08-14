import XCTest
import RxSwift
import RxTest
@testable import CDC_Interview

class FeatureFlagProviderTests: XCTestCase {

    var sut: FeatureFlagProvider!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        sut = FeatureFlagProvider()
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        sut = nil
        disposeBag = nil
        super.tearDown()
    }

    // MARK: - Core Functionality Tests

    func testDefaultValue() {
        XCTAssertFalse(sut.getValue(flag: .supportEUR))
    }

    func testUpdateFlag() {
        // Given
        XCTAssertFalse(sut.getValue(flag: .supportEUR))

        // When
        sut.update(flag: .supportEUR, newValue: true)

        // Then
        XCTAssertTrue(sut.getValue(flag: .supportEUR))
    }

    func testObserveFlagValue() {
        // Given
        var receivedValues: [Bool] = []
        let expectation = XCTestExpectation(description: "Flag value observed")
        expectation.expectedFulfillmentCount = 2

        sut.observeFlagValue(flag: .supportEUR)
            .subscribe(onNext: { value in
                receivedValues.append(value)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // When
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.sut.update(flag: .supportEUR, newValue: true)
        }

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValues, [false, true])
    }

    // MARK: - Thread Safety Tests

    func testThreadSafety() {
        let expectation = XCTestExpectation(description: "Thread safety test")
        expectation.expectedFulfillmentCount = 100

        // Simulate concurrent access
        for i in 0..<100 {
            DispatchQueue.global().async {
                self.sut.update(flag: .supportEUR, newValue: i % 2 == 0)
                let _ = self.sut.getValue(flag: .supportEUR)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
        // If we reach here without crashes, thread safety is working
    }

    // MARK: - Performance Tests

    func testDistinctUntilChanged() {
        // Given
        var emissionCount = 0
        let expectation = XCTestExpectation(description: "Distinct emissions")
        expectation.expectedFulfillmentCount = 2 // Initial + one change

        sut.observeFlagValue(flag: .supportEUR)
            .subscribe(onNext: { _ in
                emissionCount += 1
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        // When - Update with same value multiple times
        sut.update(flag: .supportEUR, newValue: true)
        sut.update(flag: .supportEUR, newValue: true) // Should not emit
        sut.update(flag: .supportEUR, newValue: true) // Should not emit

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(emissionCount, 2) // Initial false + changed to true
    }
}
