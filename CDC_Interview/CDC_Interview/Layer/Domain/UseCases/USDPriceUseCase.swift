
import Foundation
import RxSwift
import RxCocoa

class USDPriceUseCase {
    static var shared: USDPriceUseCase = .init()

    private let disposeBag = DisposeBag()
    private let repository: MarketsRepositoryProtocol

    init() {
        self.repository = MarketsRepository()
    }

    init(repository: MarketsRepositoryProtocol) {
        self.repository = repository
    }

    func fetchItems() -> Observable<[USDPrice.Price]> {
        return repository.asSingle { try await self.repository.fetchUSDPrices() }
            .asObservable()
    }

    func fetchItemsAsync() async throws -> [USDPrice.Price] {
        return try await repository.fetchUSDPrices()
    }
}
