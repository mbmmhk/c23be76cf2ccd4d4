//
//  MarketsRepository.swift
//  CDC_Interview
//
//  Created by Junjie Gu on 2025/8/14.
//

import Foundation
import RxSwift

/// Markets repository implementation
/// Provides market price data access with dual API support: async/await and RxSwift Single
/// Acts as an abstraction layer between business logic and data sources
class MarketsRepository: MarketsRepositoryProtocol {

    // MARK: - Properties

    /// Data source for fetching raw data
    private let dataSource: DataSourceProtocol

    // MARK: - Initialization

    /// Initialize with network provider type
    /// - Parameter networkProvider: Network provider type that determines the data source
    init(networkProvider: NetworkProviderType = .local) {
        switch networkProvider {
        case .local:
            self.dataSource = LocalDataSourceProvider()

        case .remote(let baseURL):
            self.dataSource = RemoteDataSourceProvider(baseURL: baseURL)
        }
    }

    // MARK: - MarketsRepositoryProtocol Implementation

    /// Asynchronously fetch USD price data
    /// - Returns: Array of USD prices extracted from raw data
    /// - Throws: Errors that occur during data fetching or parsing
    func fetchUSDPrices() async throws -> [USDPrice.Price] {
        // Fetch USD price data using the usdPrices data type identifier
        let usdPrice: USDPrice = try await dataSource.fetchData(forDataType: .usdPrices)
        return usdPrice.data
    }

    /// Asynchronously fetch all price data (including USD and EUR)
    /// - Returns: Array of all prices extracted from raw data
    /// - Throws: Errors that occur during data fetching or parsing
    func fetchAllPrices() async throws -> [AllPrice.Price] {
        // Fetch all price data using the allPrices data type identifier
        let allPrice: AllPrice = try await dataSource.fetchData(forDataType: .allPrices)
        return allPrice.data
    }
}
