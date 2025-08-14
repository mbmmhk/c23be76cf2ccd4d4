//
//  DataSourceConfiguration.swift
//  CDC_Interview
//
//  Created by Junjie Gu on 2025/8/14.
//

import Foundation

/// Data source configuration management
struct DataSourceConfiguration {
    /// Network delay simulation configuration
    /// Controls whether to simulate network delays for local data sources
    static let networkDelaySimulation: TimeInterval = {
        return 1.0
    }()
}
