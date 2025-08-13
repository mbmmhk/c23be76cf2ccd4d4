import XCTest
import RxSwift
import RxTest
@testable import CDC_Interview

// MARK: - Test Protocol and Classes
private protocol TestServiceProtocol {
    var identifier: String { get }
}

private final class TestService: TestServiceProtocol {
    let identifier: String
    let creationTime: Date

    init(identifier: String = "TestService") {
        self.identifier = identifier
        self.creationTime = Date()
    }
}

private final class ExpensiveService: TestServiceProtocol {
    let identifier: String
    let processingTime: TimeInterval
    let creationTime: Date

    init(identifier: String = "ExpensiveService", processingTime: TimeInterval = 0.1) {
        self.identifier = identifier
        self.processingTime = processingTime
        self.creationTime = Date()
        Thread.sleep(forTimeInterval: processingTime)
    }
}

private final class CountingService {
    static var instanceCount = 0
    let instanceNumber: Int

    init() {
        CountingService.instanceCount += 1
        self.instanceNumber = CountingService.instanceCount
    }

    static func resetCount() {
        instanceCount = 0
    }
}

// MARK: - Dependency Thread Safety Tests
final class DependencyTests: XCTestCase {

    var dependency: Dependency!

    override func setUp() {
        super.setUp()
        dependency = Dependency()
        CountingService.resetCount()
    }

    override func tearDown() {
        dependency = nil
        CountingService.resetCount()
        super.tearDown()
    }

    // MARK: - Basic Functionality Tests

    func testRegisterAndResolve() {
        // Given
        dependency.register(TestService.self) { _ in
            TestService(identifier: "BasicTest")
        }

        // When
        let service = dependency.resolve(TestService.self)

        // Then
        XCTAssertNotNil(service)
        XCTAssertEqual(service?.identifier, "BasicTest")
    }

    func testResolveReturnsSameInstance() {
        // Given
        dependency.register(TestService.self) { _ in
            TestService(identifier: "Singleton")
        }

        // When
        let service1 = dependency.resolve(TestService.self)
        let service2 = dependency.resolve(TestService.self)

        // Then
        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        XCTAssertTrue(service1 === service2)
        XCTAssertEqual(service1?.creationTime, service2?.creationTime)
    }

    func testResolveUnregisteredServiceReturnsNil() {
        // When
        let service = dependency.resolve(TestService.self)

        // Then
        XCTAssertNil(service)
    }

    func testRegisterMultipleTypes() {
        // Given
        dependency.register(TestService.self) { _ in
            TestService(identifier: "Service1")
        }

        dependency.register(ExpensiveService.self) { _ in
            ExpensiveService(identifier: "Service2", processingTime: 0.01)
        }

        // When
        let basicService = dependency.resolve(TestService.self)
        let expensiveService = dependency.resolve(ExpensiveService.self)

        // Then
        XCTAssertNotNil(basicService)
        XCTAssertNotNil(expensiveService)
        XCTAssertEqual(basicService?.identifier, "Service1")
        XCTAssertEqual(expensiveService?.identifier, "Service2")
    }

    func testFactoryReceivesDependency() {
        // Given
        var capturedDependency: Dependency?

        dependency.register(TestService.self) { container in
            capturedDependency = container
            return TestService(identifier: "DependencyTest")
        }

        // When
        let service = dependency.resolve(TestService.self)

        // Then
        XCTAssertNotNil(service)
        XCTAssertNotNil(capturedDependency)
        XCTAssertTrue(capturedDependency === dependency)
    }

    // MARK: - Thread Safety Tests

    func testRegisterConcurrently() {
        let expectation = XCTestExpectation(description: "Concurrent registration")
        expectation.expectedFulfillmentCount = 10

        // Given
        for index in 0..<10 {
            DispatchQueue.global().async {
                self.dependency.register(String.self) { _ in
                    "Service-\(index)"
                }
                expectation.fulfill()
            }
        }

        // When
        wait(for: [expectation], timeout: 5.0)
        Thread.sleep(forTimeInterval: 0.1)

        // Then
        let service = dependency.resolve(String.self)
        XCTAssertNotNil(service)
        XCTAssertTrue(service?.hasPrefix("Service-") == true)
    }

    func testResolveConcurrently() {
        // Given
        dependency.register(ExpensiveService.self) { _ in
            ExpensiveService(identifier: "ConcurrentTest", processingTime: 0.05)
        }

        let expectation = XCTestExpectation(description: "Concurrent resolution")
        expectation.expectedFulfillmentCount = 5

        var services: [ExpensiveService?] = []
        let lock = NSLock()

        // When
        for _ in 0..<5 {
            DispatchQueue.global().async {
                let service = self.dependency.resolve(ExpensiveService.self)
                lock.lock()
                services.append(service)
                lock.unlock()
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10.0)

        // Then
        XCTAssertEqual(services.count, 5)
        let resolvedServices = services.compactMap { $0 }
        XCTAssertEqual(resolvedServices.count, 5)

        let firstService = resolvedServices.first!
        for service in resolvedServices {
            XCTAssertTrue(firstService === service)
            XCTAssertEqual(firstService.creationTime, service.creationTime)
        }
    }

    func testMixedOperationsConcurrently() {
        let expectation = XCTestExpectation(description: "Mixed concurrent operations")
        expectation.expectedFulfillmentCount = 20

        var results: [String] = []
        let lock = NSLock()

        // Given
        for index in 0..<20 {
            DispatchQueue.global().async {
                if index % 2 == 0 {
                    self.dependency.register(Int.self) { _ in
                        index
                    }
                    lock.lock()
                    results.append("Registered-\(index)")
                    lock.unlock()
                } else {
                    let service = self.dependency.resolve(Int.self)
                    lock.lock()
                    results.append("Resolved-\(service?.description ?? "nil")")
                    lock.unlock()
                }
                expectation.fulfill()
            }
        }

        // When
        wait(for: [expectation], timeout: 10.0)

        // Then
        XCTAssertEqual(results.count, 20)

        let service = dependency.resolve(Int.self)
        XCTAssertNotNil(service)
    }

    func testSingletonWithConcurrency() {
        // Given
        dependency.register(CountingService.self) { _ in
            CountingService()
        }

        let expectation = XCTestExpectation(description: "Concurrent singleton creation")
        expectation.expectedFulfillmentCount = 10

        var services: [CountingService?] = []
        let lock = NSLock()

        // When
        for _ in 0..<10 {
            DispatchQueue.global().async {
                let service = self.dependency.resolve(CountingService.self)
                lock.lock()
                services.append(service)
                lock.unlock()
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)

        // Then
        let resolvedServices = services.compactMap { $0 }
        XCTAssertEqual(resolvedServices.count, 10)
        XCTAssertEqual(CountingService.instanceCount, 1)

        let firstService = resolvedServices.first!
        for service in resolvedServices {
            XCTAssertTrue(firstService === service)
            XCTAssertEqual(firstService.instanceNumber, service.instanceNumber)
        }
    }

    // MARK: - Edge Cases and Error Handling

    func testResolveUnregisteredType() {
        // Given
        dependency.register(TestService.self) { _ in
            TestService(identifier: "WillBeNil")
        }

        // When
        let service = dependency.resolve(ExpensiveService.self)

        // Then
        XCTAssertNil(service)
    }

    func testFactoryWithCorrectType() {
        // Given
        dependency.register(TestService.self) { _ -> TestService in
            return TestService(identifier: "CorrectType")
        }

        // When
        let service = dependency.resolve(TestService.self)

        // Then
        XCTAssertNotNil(service)
        XCTAssertEqual(service?.identifier, "CorrectType")
    }

    func testRegisterOverwritesPrevious() {
        // Given
        dependency.register(TestService.self) { _ in
            TestService(identifier: "First")
        }

        // When
        dependency.register(TestService.self) { _ in
            TestService(identifier: "Second")
        }

        Thread.sleep(forTimeInterval: 0.1)

        // Then
        let service = dependency.resolve(TestService.self)
        XCTAssertNotNil(service)
        XCTAssertEqual(service?.identifier, "Second")
    }

    func testDependencyInjection() {
        class ServiceA {
            let serviceB: ServiceB
            init(serviceB: ServiceB) {
                self.serviceB = serviceB
            }
        }

        class ServiceB {
            let identifier = "ServiceB"
        }

        // Given
        dependency.register(ServiceB.self) { _ in
            ServiceB()
        }

        dependency.register(ServiceA.self) { container in
            let serviceB = container.resolve(ServiceB.self)!
            return ServiceA(serviceB: serviceB)
        }

        // When
        let serviceA = dependency.resolve(ServiceA.self)

        // Then
        XCTAssertNotNil(serviceA)
        XCTAssertEqual(serviceA?.serviceB.identifier, "ServiceB")
    }

    func testConcurrentAccessPerformance() {
        // Given
        dependency.register(TestService.self) { _ in
            TestService(identifier: "PerformanceTest")
        }

        // When
        measure {
            let expectation = XCTestExpectation(description: "Performance test")
            expectation.expectedFulfillmentCount = 100

            for _ in 0..<100 {
                DispatchQueue.global().async {
                    let _ = self.dependency.resolve(TestService.self)
                    expectation.fulfill()
                }
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }

    func testRegistrationPerformance() {
        // When
        measure {
            for i in 0..<1000 {
                dependency.register(String.self) { _ in
                    "Service-\(i)"
                }
            }
        }
    }

    // MARK: - Memory Management Tests

    func testMemoryManagement() {
        var container: Dependency? = Dependency()

        // Given
        container?.register(TestService.self) { _ in
            TestService(identifier: "WeakSelfTest")
        }

        // When
        weak var weakContainer = container
        container = nil

        Thread.sleep(forTimeInterval: 0.1)

        // Then
        XCTAssertNil(weakContainer)
    }

    func testBackwardCompatibility() {
        // Given
        dependency.register(TestService.self) { _ in
            TestService(identifier: "BackwardCompatible")
        }

        // When
        Thread.sleep(forTimeInterval: 0.1)
        let service = dependency.resolve(TestService.self)

        // Then
        XCTAssertNotNil(service)
        XCTAssertEqual(service?.identifier, "BackwardCompatible")
    }

    func testSharedInstance() {
        // Given
        let shared = Dependency.shared

        shared.register(TestService.self) { _ in
            TestService(identifier: "SharedInstance")
        }

        Thread.sleep(forTimeInterval: 0.1)

        // When
        let service = shared.resolve(TestService.self)

        // Then
        XCTAssertNotNil(service)
        XCTAssertEqual(service?.identifier, "SharedInstance")
    }
}
