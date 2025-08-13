
import Foundation
import RxSwift
import RxCocoa

class USDPriceUseCase {
    static var shared: USDPriceUseCase = .init()

    private let disposeBag = DisposeBag()
    
    func fetchItems() -> Observable<[USDPrice.Price]> {
        let itemsObservable = Observable<[USDPrice.Price]>.create { observer in
            DispatchQueue.global()
                .asyncAfter(deadline: .now() + 2) { // Note: add 2 seconds to simulate API response time
                let path = Bundle.main.path(forResource: "usdPrices", ofType: "json")!
                guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                    observer.onError(NSError(domain: "File Error", code: 404, userInfo: nil))
                    observer.onCompleted()
                    return
                }
                
                do {
                    let items = try JSONDecoder().decode(USDPrice.self, from: data)
                    DispatchQueue.main.async {
                        observer.onNext(items.data)
                        observer.onCompleted()
                    }
                } catch {
                    DispatchQueue.main.async {
                        observer.onError(NSError(domain: "Decoding Error: \(error)", code: 0, userInfo: nil))
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
        
        return itemsObservable
    }

    func fetchItemsAsync() async throws -> [USDPrice.Price] {
        try await fetchItems().take(1).asSingle().value
    }
}
