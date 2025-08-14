//
//  DataSourceProtocol.swift
//  CDC_Interview
//
//  Created by Junjie Gu on 2025/8/13.
//

import Foundation
import RxSwift

/// Clean data source protocol with primary async/await API
protocol DataSourceProtocol: AnyObject {
    /// Asynchronously fetch data for a specific data type
    /// - Parameter forDataType: The data type identifier specifying what kind of data to fetch
    /// - Returns: Decoded data of the specified type
    /// - Throws: Errors that occur during data fetching or parsing
    func fetchData<T: Decodable>(forDataType dataType: DataSourceResource) async throws -> T
}

// MARK: - DataSource Errors

/// Errors that can occur during data source operations
enum DataSourceError: Error {
    case instanceDeallocated

    var localizedDescription: String {
        switch self {
        case .instanceDeallocated:
            return "Data source instance has been deallocated"
        }
    }
}

// MARK: - RxSwift Compatibility Extension

/// RxSwift compatibility extension
extension DataSourceProtocol {
    /// Fetch data as Single (converted from async/await) - preferred method
    /// This method provides safe conversion from async/await to RxSwift Single
    /// with proper thread scheduling: background execution, main thread completion
    /// - Parameter forDataType: The data type identifier specifying what kind of data to fetch
    /// - Returns: Single containing the decoded data
    func fetchDataSingle<T: Decodable>(forDataType dataType: DataSourceResource) -> Single<T> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.failure(DataSourceError.instanceDeallocated))
                return Disposables.create()
            }

            let task = Task {
                do {
                    let result: T = try await self.fetchData(forDataType: dataType)
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
