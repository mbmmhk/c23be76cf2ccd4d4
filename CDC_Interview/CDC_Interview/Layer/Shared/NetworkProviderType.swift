//
//  NetworkProviderType.swift
//  CDC_Interview
//
//  Created by Junjie Gu on 2025/8/14.
//

import Foundation

/// Network provider type enumeration
/// Defines supported network provider types for flexible data source configuration
enum NetworkProviderType {
    /// Local JSON file data source
    case local

    /// Remote API data source
    case remote(baseURL: String)

    // MARK: - Convenience Properties

    /// Default remote configuration
    static let defaultRemote = NetworkProviderType.remote(baseURL: "https://api.crypto.com")

    // MARK: - Description

    var description: String {
        switch self {
        case .local:
            return "Local Data Source"

        case .remote(let baseURL):
            return "Remote Data Source (\(baseURL))"
        }
    }
}
