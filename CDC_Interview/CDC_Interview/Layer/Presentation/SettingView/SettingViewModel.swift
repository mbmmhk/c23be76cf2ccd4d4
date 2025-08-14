//
//  SettingViewModel.swift
//  CDC_Interview
//
//  Created by Junjie Gu on 2025/8/14.
//

import Foundation

class SettingViewModel: ObservableObject {
    @Published var supportEUR: Bool = false {
        didSet {
            featureFlagProvider.update(flag: .supportEUR, newValue: supportEUR)
        }
    }

    private let featureFlagProvider: FeatureFlagProviderProtocol

    init(dependencyProvider: Dependency = Dependency.shared) {
        guard let featureFlagProvider = dependencyProvider.resolve(FeatureFlagProviderProtocol.self) else {
            fatalError("FeatureFlagProviderProtocol is not registered in dependency container")
        }

        self.featureFlagProvider = featureFlagProvider
        self.supportEUR = self.featureFlagProvider.getValue(flag: .supportEUR)
    }
}
