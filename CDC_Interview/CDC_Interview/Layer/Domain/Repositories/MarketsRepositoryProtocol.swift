//
//  MarketsRepositoryType.swift
//  CDC_Interview
//
//  Created by Junjie Gu on 2025/8/14.
//

import Foundation
import RxSwift

/// Markets data repository protocol
/// Defines market price data access interface with primary async/await API
protocol MarketsRepositoryProtocol: AnyObject {

    // MARK: - async/await API

    /// Asynchronously fetch USD price data
    /// - Returns: Array of USD prices
    /// - Throws: Errors that occur during data fetching
    func fetchUSDPrices() async throws -> [USDPrice.Price]

    /// Asynchronously fetch all price data (including USD and EUR)
    /// - Returns: Array of all prices
    /// - Throws: Errors that occur during data fetching
    func fetchAllPrices() async throws -> [AllPrice.Price]
}

// MARK: - Repository Errors

/// Errors that can occur during repository operations
enum RepositoryError: Error {
    case instanceDeallocated

    var localizedDescription: String {
        switch self {
        case .instanceDeallocated:
            return "Repository instance has been deallocated"
        }
    }
}

// MARK: - RxSwift Generic Extension

/// RxSwift compatibility extension with generic method
extension MarketsRepositoryProtocol {
    /// Generic method to convert any async operation to RxSwift Single
    /// This provides elegant RxSwift support without duplicating repository methods
    /// - Parameter operation: The async operation to convert
    /// - Returns: Single containing the result of the async operation
    func asSingle<T>(_ operation: @escaping () async throws -> T) -> Single<T> {
        return Single.create { [weak self] observer in
            guard self != nil else {
                observer(.failure(RepositoryError.instanceDeallocated))
                return Disposables.create()
            }

            let task = Task {
                do {
                    let result = try await operation()
                    observer(.success(result))
                } catch {
                    observer(.failure(error))
                }
            }

            return Disposables.create {
                task.cancel()
            }
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
        .observe(on: MainScheduler.instance)
    }
}
