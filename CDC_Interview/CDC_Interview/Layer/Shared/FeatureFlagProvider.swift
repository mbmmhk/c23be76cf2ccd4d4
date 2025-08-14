
import Foundation
import RxCocoa
import RxSwift

enum FeatureFlagType {
    case supportEUR
}

/// Protocol defining the interface for feature flag management
/// Provides methods to observe, retrieve, and update feature flag values
protocol FeatureFlagProviderProtocol {

    /// Observes changes to a specific feature flag value
    /// - Parameter flag: The feature flag to observe
    /// - Returns: Observable that emits the current flag value and any subsequent changes
    func observeFlagValue(flag: FeatureFlagType) -> Observable<Bool>

    /// Gets the current value of a feature flag
    /// - Parameter flag: The feature flag to query
    /// - Returns: Current boolean value of the flag
    func getValue(flag: FeatureFlagType) -> Bool

    /// Updates the value of a feature flag
    /// - Parameters:
    ///   - flag: The feature flag to update
    ///   - newValue: The new boolean value to set
    func update(flag: FeatureFlagType, newValue: Bool)
}

class FeatureFlagProvider: FeatureFlagProviderProtocol {

    // MARK: - FeatureFlagProvider
    private let flagsRelay: BehaviorRelay<[FeatureFlagType: Bool]>
    private let lock = NSLock() // Thread safety

    init() {
        self.flagsRelay = BehaviorRelay(
            value: [
                .supportEUR: false
            ]
        )
    }

    func observeFlagValue(flag: FeatureFlagType) -> Observable<Bool> {
        return flagsRelay
            .map { $0[flag] ?? false }
            .distinctUntilChanged() // Performance: avoid duplicate emissions
    }

    func getValue(flag: FeatureFlagType) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return flagsRelay.value[flag] ?? false
    }

    func update(flag: FeatureFlagType, newValue: Bool) {
        lock.lock()
        var existing = flagsRelay.value
        existing[flag] = newValue
        flagsRelay.accept(existing)
        lock.unlock()
    }
}
