
import Foundation
import RxSwift
import RxCocoa

class AllPriceUseCase {
    static var shared: AllPriceUseCase = .init()

    private let disposeBag = DisposeBag()
    private let repository: MarketsRepositoryProtocol

    init() {
        self.repository = MarketsRepository()
    }

    init(repository: MarketsRepositoryProtocol) {
        self.repository = repository
    }

    func fetchItems() -> Observable<[AllPrice.Price]> {
        return repository.asSingle { try await self.repository.fetchAllPrices() }
            .asObservable()
    }

    func fetchItemsAsync() async throws -> [AllPrice.Price] {
        return try await repository.fetchAllPrices()
    }
}
