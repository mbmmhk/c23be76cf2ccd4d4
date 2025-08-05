
import XCTest
import RxTest
import RxSwift
@testable import CDC_Interview

final class CDC_InterviewTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetch() throws {
        let disposeBag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)

        let dep = Dependency()
        dep.register(USDPriceUseCase.self) { _ in
            let mock = MockUSDPriceUseCase()
            mock.stubbedFetchItemsResult = scheduler.createColdObservable([
                .next(0, []),
                .next(10, [USDPrice.init(id: 1, name: "a", usd: 1, tags: [.deposit])])
            ]).asObservable()
            
            return mock
        }
        
        dep.register(AllPriceUseCase.self) { _ in
            MockAllPriceUseCase()
        }
        
        dep.register(USDPriceUseCase.self) { _ in
            let mock = MockUSDPriceUseCase()
            mock.stubbedFetchItemsResult = scheduler.createColdObservable([
                .next(0, []),
                .next(10, [USDPrice.init(id: 1, name: "a", usd: 1, tags: [.deposit])])
            ]).asObservable()
            
            return mock
        }
        
        dep.register(FeatureFlagProvider.self) { _ in
            let provider = FeatureFlagProvider()
            provider.update(falg: .supportEUR, newValue: false)
            return provider
        }
        
        let vc = ListViewController()
        
        let itemsObserver = scheduler.createObserver([InstrumentPriceCell.ViewModel].self)
        vc.itemsObservable.distinctUntilChanged().bind(to: itemsObserver).disposed(by: disposeBag)
        vc.fetchItems(searchText: nil).subscribe().disposed(by: disposeBag)
                
        XCTAssertEqual(itemsObserver.events, [
            .next(0, []),
            .next(10, [InstrumentPriceCell.ViewModel(usdPrice: USDPrice.init(id: 1, name: "a", usd: 1, tags: [.deposit]))]),
        ])
    }
}

class MockUSDPriceUseCase: USDPriceUseCase {
    var stubbedFetchItemsResult: Observable<[USDPrice]>!
    override func fetchItems() -> Observable<[USDPrice]> {
        return stubbedFetchItemsResult
    }
}

class MockAllPriceUseCase: AllPriceUseCase {
    var stubbedFetchItemsResult: Observable<AllPrice.Price>!
    override func fetchItems() -> Observable<AllPrice.Price> {
        return stubbedFetchItemsResult
    }
}
