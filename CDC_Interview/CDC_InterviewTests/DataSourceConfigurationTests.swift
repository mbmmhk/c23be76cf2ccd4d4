//
//  DataSourceConfigurationTests.swift
//  CDC_InterviewTests
//
//  Created by Junjie Gu on 2025/8/14.
//

import XCTest
@testable import CDC_Interview

final class DataSourceConfigurationTests: XCTestCase {

    // MARK: - Network Delay Simulation Tests

    func testNetworkDelaySimulation_DebugBuild_ReturnsOneSecond() {
        // Given & When
        let delaySeconds = DataSourceConfiguration.networkDelaySimulation
        
        // Then
        #if DEBUG
        XCTAssertEqual(delaySeconds, 1.0, "Debug build should simulate 1 second network delay")
        #else
        XCTAssertEqual(delaySeconds, 0.0, "Release build should have no delay simulation")
        #endif
    }
    
    func testNetworkDelaySimulation_IsPositiveValue() {
        // Given & When
        let delaySeconds = DataSourceConfiguration.networkDelaySimulation
        
        // Then
        XCTAssertGreaterThanOrEqual(delaySeconds, 0.0, "Network delay should not be negative")
    }
    
    func testNetworkDelaySimulation_IsReasonableValue() {
        // Given & When
        let delaySeconds = DataSourceConfiguration.networkDelaySimulation
        
        // Then
        XCTAssertLessThanOrEqual(delaySeconds, 5.0, "Network delay should not exceed 5 seconds for reasonable simulation")
    }
    
    // MARK: - Configuration Consistency Tests
    
    func testNetworkDelaySimulation_IsConsistentAcrossMultipleCalls() {
        // Given
        let firstCall = DataSourceConfiguration.networkDelaySimulation
        let secondCall = DataSourceConfiguration.networkDelaySimulation
        let thirdCall = DataSourceConfiguration.networkDelaySimulation
        
        // Then
        XCTAssertEqual(firstCall, secondCall, "Network delay should be consistent across calls")
        XCTAssertEqual(secondCall, thirdCall, "Network delay should be consistent across calls")
        XCTAssertEqual(firstCall, thirdCall, "Network delay should be consistent across calls")
    }
    
    // MARK: - Build Configuration Tests
    
    func testNetworkDelaySimulation_BuildSpecificBehavior() {
        // Given & When
        let delaySeconds = DataSourceConfiguration.networkDelaySimulation
        
        // Then
        #if DEBUG
        XCTAssertGreaterThan(delaySeconds, 0.0, "Debug builds should have network delay simulation enabled")
        XCTAssertEqual(delaySeconds, 1.0, "Debug builds should use exactly 1 second delay")
        #else
        XCTAssertEqual(delaySeconds, 0.0, "Release builds should have no network delay simulation")
        #endif
    }
    
    // MARK: - Integration Tests
    
    func testNetworkDelaySimulation_CanBeUsedInAsyncContext() async {
        // Given
        let delaySeconds = DataSourceConfiguration.networkDelaySimulation
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // When
        if delaySeconds > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
        }
        
        // Then
        let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
        
        if delaySeconds > 0 {
            XCTAssertGreaterThanOrEqual(elapsedTime, delaySeconds - 0.1, "Should wait for at least the configured delay")
            XCTAssertLessThan(elapsedTime, delaySeconds + 0.5, "Should not wait significantly longer than configured delay")
        } else {
            XCTAssertLessThan(elapsedTime, 0.1, "Should complete immediately when no delay is configured")
        }
    }
    
    // MARK: - Type Safety Tests
    
    func testNetworkDelaySimulation_IsTimeInterval() {
        // Given & When
        let delaySeconds = DataSourceConfiguration.networkDelaySimulation
        
        // Then
        XCTAssertTrue(type(of: delaySeconds) == TimeInterval.self, "Network delay should be of type TimeInterval")
    }
    
    // MARK: - Performance Tests
    
    func testNetworkDelaySimulation_AccessPerformance() {
        // Given
        let iterations = 1000
        
        // When & Then
        measure {
            for _ in 0..<iterations {
                _ = DataSourceConfiguration.networkDelaySimulation
            }
        }
    }
    
    // MARK: - Documentation Tests
    
    func testDataSourceConfiguration_HasCorrectStructure() {
        // Given & When
        let instance = DataSourceConfiguration()
        let mirror = Mirror(reflecting: instance)

        // Then
        XCTAssertEqual(mirror.displayStyle, .struct, "DataSourceConfiguration should be a struct")
        XCTAssertEqual(mirror.children.count, 0, "DataSourceConfiguration should have no instance properties")
    }
}
