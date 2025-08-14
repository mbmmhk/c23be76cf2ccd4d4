//
//  LocalDataProvider.swift
//  CDC_Interview
//
//  Created by Junjie Gu on 2025/8/13.
//

import Foundation
import RxSwift

enum LocalDataFetchError: Error, LocalizedError {
    case missingFile(String)
    case invalidData(Error)
    case internalError(Error)

    var errorDescription: String? {
        switch self {
        case .missingFile(let filename):
            return "Missing file: '\(filename).json'"

        case .invalidData(let error):
            return "Invalid data format: \(error.localizedDescription)"

        case .internalError(let error):
            return "Internal error: \(error.localizedDescription)"
        }
    }
}

final class LocalDataSourceProvider: DataSourceProtocol {

    private let enableLogging: Bool

    init(enableLogging: Bool? = nil) {
        if let enableLogging = enableLogging {
            self.enableLogging = enableLogging
        } else {
            #if DEBUG
            self.enableLogging = true
            #else
            self.enableLogging = false
            #endif
        }
    }

    func fetchData<T: Decodable>(forDataType dataType: DataSourceResource) async throws -> T {
        logDebug("Starting to fetch data for type: \(dataType.description)")

        // Simulate network delay based on configuration
        let delaySeconds = DataSourceConfiguration.networkDelaySimulation
        if delaySeconds > 0 {
            try await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
            logDebug("Simulated network delay: \(delaySeconds) seconds")
        }

        do {
            let data = try loadDataFromBundle(dataType: dataType)
            let result: T = try JSONDecoder().decode(T.self, from: data)
            logDebug("Successfully parsed data for type \(dataType.description)")
            return result

        } catch let decodingError as DecodingError {
            logError("Decoding failed: \(decodingError.localizedDescription)")
            throw LocalDataFetchError.invalidData(decodingError)

        } catch let dataFetchError as LocalDataFetchError {
            logError("Data fetch failed: \(dataFetchError.localizedDescription)")
            throw dataFetchError

        } catch {
            logError("Internal error: \(error.localizedDescription)")
            throw LocalDataFetchError.internalError(error)
        }
    }
}

// MARK: - Private Helper Methods

private extension LocalDataSourceProvider {
    func loadDataFromBundle(dataType: DataSourceResource) throws -> Data {
        guard let path = Bundle.main.path(forResource: dataType.rawValue, ofType: dataType.fileExtension) else {
            throw LocalDataFetchError.missingFile(dataType.filename)
        }

        do {
            return try Data(contentsOf: URL(fileURLWithPath: path))

        } catch {
            throw LocalDataFetchError.internalError(error)
        }
    }

    func logDebug(_ message: String) {
        if enableLogging {
            print("[LocalDataProvider] \(message)")
        }
    }

    func logError(_ message: String) {
        if enableLogging {
            print("[LocalDataProvider] \(message)")
        }
    }
}


