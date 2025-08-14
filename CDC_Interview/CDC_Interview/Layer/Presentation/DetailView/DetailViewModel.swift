//
//  DetailViewModel.swift
//  CDC_Interview
//
//  Created by Junjie Gu on 2025/8/14.
//

import Foundation
import SwiftUI
import RxSwift
import RxCocoa

@MainActor
final class DetailViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var showEURPrice: Bool = false
    @Published var formattedPrices: String = ""

    // MARK: - Private Properties
    private let displayItem: CryptoListViewModel.DisplayItem
    private let featureFlagProvider: FeatureFlagProviderProtocol
    private let disposeBag = DisposeBag()

    // MARK: - Computed Properties
    var tokenName: String {
        displayItem.name
    }

    // MARK: - Initialization
    init(displayItem: CryptoListViewModel.DisplayItem,
         dependencyProvider: Dependency = Dependency.shared) {

        guard let featureFlagProvider = dependencyProvider.resolve(FeatureFlagProviderProtocol.self) else {
            fatalError("FeatureFlagProviderProtocol is not registered in dependency container")
        }

        self.displayItem = displayItem
        self.featureFlagProvider = featureFlagProvider

        setupRxBindings()
        updateFormattedPrices()
    }

    // MARK: - Private Methods
    private func setupRxBindings() {
        featureFlagProvider.observeFlagValue(flag: .supportEUR)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] showEUR in
                self?.showEURPrice = showEUR
                self?.updateFormattedPrices()
            })
            .disposed(by: disposeBag)
    }

    private func updateFormattedPrices() {
        if showEURPrice, let eurPrice = displayItem.eurPrice {
            formattedPrices = "USD: \(displayItem.usdPrice)\nEUR: \(eurPrice)"
        } else {
            formattedPrices = "USD: \(displayItem.usdPrice)"
        }
    }
}
