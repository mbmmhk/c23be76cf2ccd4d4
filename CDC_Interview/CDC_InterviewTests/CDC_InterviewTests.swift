
import XCTest
@testable import CDC_Interview

final class CDC_InterviewTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDependencyInjection() throws {
        // Given
        let dependency = Dependency.shared

        // When
        let priceUseCase = dependency.resolve(MarketsPriceUseCaseProtocol.self)
        let featureFlagProvider = dependency.resolve(FeatureFlagProviderProtocol.self)

        // Then
        XCTAssertNotNil(priceUseCase, "MarketsPriceUseCase should be registered")
        XCTAssertNotNil(featureFlagProvider, "FeatureFlagProvider should be registered")
    }

    func testCryptoFormatterSharedInstance() throws {
        // Given & When
        let formatter1 = CryptoFormatter.shared
        let formatter2 = CryptoFormatter.shared

        // Then
        XCTAssertTrue(formatter1 === formatter2, "CryptoFormatter should be a singleton")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            _ = CryptoFormatter.shared.formatUSD(100.0)
        }
    }
}
