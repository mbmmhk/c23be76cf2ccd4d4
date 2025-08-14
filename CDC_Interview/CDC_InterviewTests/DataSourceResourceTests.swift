//
//  DataSourceResourceTests.swift
//  CDC_InterviewTests
//
//  Created by Junjie Gu on 2025/8/14.
//

import XCTest
@testable import CDC_Interview

final class DataSourceResourceTests: XCTestCase {

    // MARK: - Raw Value Tests

    func testUSDPrices_RawValue_ReturnsCorrectString() {
        // Given & When
        let resource = DataSourceResource.usdPrices

        // Then
        XCTAssertEqual(resource.rawValue, "usdPrices", "USD prices resource should have correct raw value")
    }

    func testAllPrices_RawValue_ReturnsCorrectString() {
        // Given & When
        let resource = DataSourceResource.allPrices

        // Then
        XCTAssertEqual(resource.rawValue, "allPrices", "All prices resource should have correct raw value")
    }

    // MARK: - Description Tests

    func testUSDPrices_Description_ReturnsCorrectDescription() {
        // Given & When
        let resource = DataSourceResource.usdPrices

        // Then
        XCTAssertEqual(resource.description, "USD Price Data", "USD prices should have correct description")
    }

    func testAllPrices_Description_ReturnsCorrectDescription() {
        // Given & When
        let resource = DataSourceResource.allPrices

        // Then
        XCTAssertEqual(resource.description, "All Price Data (USD + EUR)", "All prices should have correct description")
    }

    // MARK: - File Extension Tests

    func testUSDPrices_FileExtension_ReturnsJSON() {
        // Given & When
        let resource = DataSourceResource.usdPrices

        // Then
        XCTAssertEqual(resource.fileExtension, "json", "USD prices should use JSON file extension")
    }

    func testAllPrices_FileExtension_ReturnsJSON() {
        // Given & When
        let resource = DataSourceResource.allPrices

        // Then
        XCTAssertEqual(resource.fileExtension, "json", "All prices should use JSON file extension")
    }

    func testAllResources_FileExtension_AreConsistent() {
        // Given & When
        let allResources = DataSourceResource.allCases

        // Then
        for resource in allResources {
            XCTAssertEqual(resource.fileExtension, "json", "All resources should use JSON file extension")
        }
    }

    // MARK: - Filename Tests

    func testUSDPrices_Filename_ReturnsCorrectFilename() {
        // Given & When
        let resource = DataSourceResource.usdPrices

        // Then
        XCTAssertEqual(resource.filename, "usdPrices.json", "USD prices should have correct filename")
    }

    func testAllPrices_Filename_ReturnsCorrectFilename() {
        // Given & When
        let resource = DataSourceResource.allPrices

        // Then
        XCTAssertEqual(resource.filename, "allPrices.json", "All prices should have correct filename")
    }

    func testAllResources_Filename_FollowsNamingConvention() {
        // Given & When
        let allResources = DataSourceResource.allCases

        // Then
        for resource in allResources {
            let expectedFilename = "\(resource.rawValue).json"
            XCTAssertEqual(resource.filename, expectedFilename, "Resource \(resource) should follow naming convention")
        }
    }

    // MARK: - CaseIterable Tests

    func testAllCases_ContainsExpectedResources() {
        // Given & When
        let allCases = DataSourceResource.allCases

        // Then
        XCTAssertEqual(allCases.count, 2, "Should have exactly 2 resource cases")
        XCTAssertTrue(allCases.contains(.usdPrices), "Should contain usdPrices")
        XCTAssertTrue(allCases.contains(.allPrices), "Should contain allPrices")
    }

    func testAllCases_AreUnique() {
        // Given & When
        let allCases = DataSourceResource.allCases
        let uniqueCases = Set(allCases.map { $0.rawValue })

        // Then
        XCTAssertEqual(allCases.count, uniqueCases.count, "All cases should be unique")
    }

    // MARK: - Price Resources Extension Tests

    func testPriceResources_ContainsExpectedResources() {
        // Given & When
        let priceResources = DataSourceResource.priceResources

        // Then
        XCTAssertEqual(priceResources.count, 2, "Should have exactly 2 price resources")
        XCTAssertTrue(priceResources.contains(.usdPrices), "Should contain usdPrices")
        XCTAssertTrue(priceResources.contains(.allPrices), "Should contain allPrices")
    }

    func testPriceResources_MatchesAllCases() {
        // Given & When
        let priceResources = Set(DataSourceResource.priceResources)
        let allCases = Set(DataSourceResource.allCases)

        // Then
        XCTAssertEqual(priceResources, allCases, "Price resources should match all cases for current implementation")
    }

    // MARK: - Bundle Existence Tests

    func testUSDPrices_ExistsInBundle_ReturnsTrue() {
        // Given & When
        let resource = DataSourceResource.usdPrices

        // Then
        XCTAssertTrue(resource.existsInBundle, "USD prices file should exist in bundle")
    }

    func testAllPrices_ExistsInBundle_ReturnsTrue() {
        // Given & When
        let resource = DataSourceResource.allPrices

        // Then
        XCTAssertTrue(resource.existsInBundle, "All prices file should exist in bundle")
    }

    func testAllResources_ExistInBundle() {
        // Given & When
        let allResources = DataSourceResource.allCases

        // Then
        for resource in allResources {
            XCTAssertTrue(resource.existsInBundle, "Resource \(resource.filename) should exist in bundle")
        }
    }

    // MARK: - String Conversion Tests

    func testRawValueInitialization_WithValidString_ReturnsCorrectResource() {
        // Given & When
        let usdResource = DataSourceResource(rawValue: "usdPrices")
        let allResource = DataSourceResource(rawValue: "allPrices")

        // Then
        XCTAssertEqual(usdResource, .usdPrices, "Should create usdPrices from raw value")
        XCTAssertEqual(allResource, .allPrices, "Should create allPrices from raw value")
    }

    func testRawValueInitialization_WithInvalidString_ReturnsNil() {
        // Given & When
        let invalidResource = DataSourceResource(rawValue: "invalidResource")

        // Then
        XCTAssertNil(invalidResource, "Should return nil for invalid raw value")
    }

    // MARK: - Consistency Tests

    func testAllResources_HaveNonEmptyDescriptions() {
        // Given & When
        let allResources = DataSourceResource.allCases

        // Then
        for resource in allResources {
            XCTAssertFalse(resource.description.isEmpty, "Resource \(resource) should have non-empty description")
        }
    }

    func testAllResources_HaveValidFilenames() {
        // Given & When
        let allResources = DataSourceResource.allCases

        // Then
        for resource in allResources {
            XCTAssertFalse(resource.filename.isEmpty, "Resource \(resource) should have non-empty filename")
            XCTAssertTrue(resource.filename.contains("."), "Resource \(resource) filename should contain file extension")
            XCTAssertTrue(resource.filename.hasSuffix(".json"), "Resource \(resource) filename should end with .json")
        }
    }

    // MARK: - Enum Protocol Conformance Tests

    func testDataSourceResource_HasStringRawValue() {
        // Given & When
        let resource = DataSourceResource.usdPrices

        // Then
        XCTAssertTrue(type(of: resource.rawValue) == String.self, "Raw value should be String type")
        XCTAssertFalse(resource.rawValue.isEmpty, "Raw value should not be empty")
    }

    func testDataSourceResource_ProvidesCaseIterable() {
        // Given & When
        let allCases = DataSourceResource.allCases

        // Then
        XCTAssertFalse(allCases.isEmpty, "CaseIterable should provide non-empty allCases")
        XCTAssertEqual(allCases.count, 2, "Should have exactly 2 cases")
    }

    // MARK: - Performance Tests

    func testResourceAccess_Performance() {
        // Given
        let iterations = 1000

        // When & Then
        measure {
            for _ in 0..<iterations {
                _ = DataSourceResource.usdPrices.description
                _ = DataSourceResource.allPrices.filename
                _ = DataSourceResource.priceResources
            }
        }
    }

    // MARK: - Edge Case Tests

    func testDescription_DoesNotContainRawValue() {
        // Given & When
        let allResources = DataSourceResource.allCases

        // Then
        for resource in allResources {
            // Description should be human-readable, not just the raw value
            XCTAssertNotEqual(resource.description, resource.rawValue,
                             "Description should be more descriptive than raw value for \(resource)")
        }
    }

    func testFilename_IsValidFilename() {
        // Given & When
        let allResources = DataSourceResource.allCases
        let invalidCharacters = CharacterSet(charactersIn: "/\\:*?\"<>|")

        // Then
        for resource in allResources {
            let filename = resource.filename
            XCTAssertTrue(filename.rangeOfCharacter(from: invalidCharacters) == nil,
                         "Filename '\(filename)' should not contain invalid characters")
            XCTAssertFalse(filename.hasPrefix("."), "Filename should not start with dot")
            XCTAssertTrue(filename.count > 5, "Filename should be reasonably long (more than just '.json')")
        }
    }
}
