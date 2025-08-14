//
//  DataSourceResource.swift
//  CDC_Interview
//
//  Created by Junjie Gu on 2025/8/13.
//

import Foundation

/// Data source resource enumeration
/// Defines all available data resources with type safety and prevents hardcoded strings
enum DataSourceResource: String, CaseIterable {
    
    // MARK: - Price Data Resources
    
    /// USD price data resource
    case usdPrices = "usdPrices"
    
    /// All price data resource (including USD and EUR)
    case allPrices = "allPrices"
    
    // MARK: - Future Extension Points
    // Additional resources can be added here:
    
    /// EUR price data resource
    // case eurPrices = "eurPrices"
    
    /// Bitcoin price data resource
    // case btcPrices = "btcPrices"
    
    /// Market configuration resource
    // case marketConfig = "marketConfig"
    
    // MARK: - Computed Properties
    
    /// Human-readable description of the resource
    var description: String {
        switch self {
        case .usdPrices:
            return "USD Price Data"
        case .allPrices:
            return "All Price Data (USD + EUR)"
        }
    }
    
    /// File extension for the resource (defaults to json)
    var fileExtension: String {
        return "json"
    }
    
    /// Full filename with extension
    var filename: String {
        return "\(rawValue).\(fileExtension)"
    }
}

// MARK: - Convenience Extensions

extension DataSourceResource {
    
    /// All available price resources
    static var priceResources: [DataSourceResource] {
        return [.usdPrices, .allPrices]
    }
    
    /// Check if resource exists in bundle
    var existsInBundle: Bool {
        return Bundle.main.path(forResource: rawValue, ofType: fileExtension) != nil
    }
}
