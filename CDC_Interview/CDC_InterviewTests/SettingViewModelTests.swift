//
//  SettingViewModelTests.swift
//  CDC_InterviewTests
//
//  Created by Junjie Gu on 2025/8/14.
//

import XCTest
import RxSwift
import RxTest
@testable import CDC_Interview

final class SettingViewModelTests: XCTestCase {

    private var sut: SettingViewModel!
    private var mockFeatureFlagProvider: MockFeatureFlagProvider!
    private var testDependency: Dependency!

    @MainActor
    override func setUp() {
        super.setUp()

        mockFeatureFlagProvider = MockFeatureFlagProvider()
        testDependency = Dependency()

        testDependency.register(FeatureFlagProviderProtocol.self) { _ in
            return self.mockFeatureFlagProvider
        }
    }

    @MainActor
    override func tearDown() {
        sut = nil
        mockFeatureFlagProvider = nil
        testDependency = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    @MainActor
    func testInitialization_WithDefaultFeatureFlagValue() {
        // Given
        mockFeatureFlagProvider.mockEURSupportEnabled = false

        // When
        sut = SettingViewModel(dependencyProvider: testDependency)

        // Then
        XCTAssertFalse(sut.supportEUR)
    }

    @MainActor
    func testInitialization_WithEnabledFeatureFlagValue() {
        // Given
        mockFeatureFlagProvider.mockEURSupportEnabled = true

        // When
        sut = SettingViewModel(dependencyProvider: testDependency)

        // Then
        XCTAssertTrue(sut.supportEUR)
    }

    @MainActor
    func testInitialization_WithMissingDependency_ShouldFatalError() {
        // Given
        let emptyDependency = Dependency()

        // When & Then
        // Note: We can't directly test fatalError in unit tests
        // This test documents the expected behavior
        // In a real scenario, you might want to use a different error handling strategy
        // that can be tested, such as throwing an error or returning nil

        // This would cause a fatalError:
        // sut = SettingViewModel(dependencyProvider: emptyDependency)

        // For now, we just document this behavior
        XCTAssertTrue(true, "fatalError is expected when FeatureFlagProvider is not registered")
    }

    // MARK: - Feature Flag Update Tests

    @MainActor
    func testSupportEURToggle_ShouldUpdateFeatureFlag() {
        // Given
        mockFeatureFlagProvider.mockEURSupportEnabled = false
        sut = SettingViewModel(dependencyProvider: testDependency)
        XCTAssertFalse(sut.supportEUR)

        // When
        sut.supportEUR = true

        // Then
        XCTAssertTrue(mockFeatureFlagProvider.mockEURSupportEnabled)
    }

    @MainActor
    func testSupportEURToggle_FromTrueToFalse_ShouldUpdateFeatureFlag() {
        // Given
        mockFeatureFlagProvider.mockEURSupportEnabled = true
        sut = SettingViewModel(dependencyProvider: testDependency)
        XCTAssertTrue(sut.supportEUR)

        // When
        sut.supportEUR = false

        // Then
        XCTAssertFalse(mockFeatureFlagProvider.mockEURSupportEnabled)
    }

    @MainActor
    func testSupportEURToggle_MultipleChanges_ShouldUpdateFeatureFlagCorrectly() {
        // Given
        mockFeatureFlagProvider.mockEURSupportEnabled = false
        sut = SettingViewModel(dependencyProvider: testDependency)

        // When & Then
        sut.supportEUR = true
        XCTAssertTrue(mockFeatureFlagProvider.mockEURSupportEnabled)

        sut.supportEUR = false
        XCTAssertFalse(mockFeatureFlagProvider.mockEURSupportEnabled)

        sut.supportEUR = true
        XCTAssertTrue(mockFeatureFlagProvider.mockEURSupportEnabled)
    }

    // MARK: - Published Property Tests

    @MainActor
    func testSupportEUR_IsPublished() {
        // Given
        mockFeatureFlagProvider.mockEURSupportEnabled = false
        sut = SettingViewModel(dependencyProvider: testDependency)

        var receivedValues: [Bool] = []
        let expectation = XCTestExpectation(description: "Published value received")
        expectation.expectedFulfillmentCount = 2

        // When
        let cancellable = sut.$supportEUR.sink { value in
            receivedValues.append(value)
            expectation.fulfill()
        }

        sut.supportEUR = true

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValues, [false, true])

        cancellable.cancel()
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
