//
//  RemoteDataSourceProvider.swift
//  CDC_Interview
//
//  Created by Junjie Gu on 2025/8/14.
//

import Foundation

/// Remote data source provider - placeholder implementation for demonstration
final class RemoteDataSourceProvider: DataSourceProtocol {
    private let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    func fetchData<T: Decodable>(forDataType dataType: DataSourceResource) async throws -> T {
        // Placeholder: Just throw not implemented error
        throw RemoteDataFetchError.notImplemented
    }
}

// MARK: - Error

enum RemoteDataFetchError: Error, LocalizedError {
    case notImplemented

    var errorDescription: String? {
        return "RemoteDataSourceProvider is not implemented - this is just a demo"
    }
}
