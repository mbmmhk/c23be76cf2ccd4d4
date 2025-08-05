
import Foundation
import RxSwift
import RxCocoa

class AllPriceUseCase {
    static var shared: AllPriceUseCase = .init()

    private let disposeBag = DisposeBag()

    func fetchItems() -> Observable<[AllPrice.Price]> {
        let itemsObservable = Observable<[AllPrice.Price]>.create { observer in
            DispatchQueue.global()
                .asyncAfter(deadline: .now() + 2) { // Note: add 2 seconds to simulate API response time
                let path = Bundle.main.path(forResource: "allPrices", ofType: "json")!
                guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                      let allPrices = try? JSONDecoder().decode(AllPrice.self, from: data) else {
                    observer.onError(NSError(domain: "File Error", code: 404, userInfo: nil))
                    return
                }
                DispatchQueue.main.async {
                    observer.onNext(allPrices.data)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
        
        return itemsObservable
    }

    func fetchItemsAsync() async throws -> [AllPrice.Price] {
        try await fetchItems().take(1).asSingle().value
    }
}
