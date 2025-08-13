
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
    
    func observeFlagValue(flag: FeatureFlagType) -> Observable<Bool> {
        flagsRelay.map {
            $0[flag] ?? false
        }
    }

    func getValue(flag: FeatureFlagType) -> Bool {
        flagsRelay.value[flag] ?? false
    }

    func update(flag: FeatureFlagType, newValue: Bool) {
        var existing = flagsRelay.value
        existing[flag] = newValue
        flagsRelay.accept(existing)
    }
}
