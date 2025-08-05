
import Foundation
import RxCocoa
import RxSwift

enum FeatureFlagType {
    case supportEUR
}

class FeatureFlagProvider {
    let flagsRelay: BehaviorRelay<[FeatureFlagType: Bool]> = .init(
        value: [
            .supportEUR: false
        ]
    )
    
    func observeFlagValue(falg: FeatureFlagType) -> Observable<Bool> {
        flagsRelay.map {
            $0[falg] ?? false
        }
    }
    
    func getValue(falg: FeatureFlagType) -> Bool {
        flagsRelay.value[falg] ?? false
    }
    
    func update(falg: FeatureFlagType, newValue: Bool) {
        var existing = flagsRelay.value
        existing[falg] = newValue
        flagsRelay.accept(existing)
    }
}
