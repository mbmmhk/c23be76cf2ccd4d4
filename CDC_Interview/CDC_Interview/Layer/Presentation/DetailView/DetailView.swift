//
//  DetailView.swift
//  CDC_Interview
//
//  Created by Junjie Gu on 2025/8/14.
//

import SwiftUI
import RxSwift

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(displayItem: CryptoListViewModel.DisplayItem, dependencyProvider: Dependency = Dependency.shared) {
        self._viewModel = StateObject(wrappedValue: DetailViewModel(displayItem: displayItem, dependencyProvider: dependencyProvider))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Divider()

            // Price information
            VStack(alignment: .leading, spacing: 12) {
                Text("Current Price")
                    .font(.headline)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.formattedPrices.components(separatedBy: "\n"), id: \.self) { priceString in
                        if !priceString.isEmpty {
                            Text(priceString)
                                .font(.title2)
                                .fontWeight(.medium)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .navigationTitle(viewModel.tokenName)
    }
}

// MARK: - Preview
#Preview("USD Only") {
    // Create a mock dependency with EUR support disabled
    let mockDependency = Dependency()
    mockDependency.register(FeatureFlagProviderProtocol.self) { _ in
        let mockProvider = MockFeatureFlagProviderForPreview()
        mockProvider.mockEURSupportEnabled = false
        return mockProvider
    }

    return NavigationView {
        DetailView(
            displayItem: CryptoListViewModel.DisplayItem(
                id: 1,
                name: "BTC",
                symbol: "BTC",
                usdPrice: "$29,130.52",
                eurPrice: nil,
                tags: ["withdrawal", "deposit"],
                showEUR: false
            ),
            dependencyProvider: mockDependency
        )
    }
}

#Preview("USD and EUR") {
    // Create a mock dependency with EUR support enabled
    let mockDependency = Dependency()
    mockDependency.register(FeatureFlagProviderProtocol.self) { _ in
        let mockProvider = MockFeatureFlagProviderForPreview()
        mockProvider.mockEURSupportEnabled = true
        return mockProvider
    }

    return NavigationView {
        DetailView(
            displayItem: CryptoListViewModel.DisplayItem(
                id: 1,
                name: "BTC",
                symbol: "BTC",
                usdPrice: "$29,130.52",
                eurPrice: "€27,084.11",
                tags: ["withdrawal", "deposit"],
                showEUR: true
            ),
            dependencyProvider: mockDependency
        )
    }
}

// MARK: - Preview Mock
private class MockFeatureFlagProviderForPreview: FeatureFlagProviderProtocol {
    var mockEURSupportEnabled: Bool = false

    func observeFlagValue(flag: FeatureFlagType) -> Observable<Bool> {
        return .just(mockEURSupportEnabled)
    }

    func getValue(flag: FeatureFlagType) -> Bool {
        return mockEURSupportEnabled
    }

    func update(flag: FeatureFlagType, newValue: Bool) {
        if flag == .supportEUR {
            mockEURSupportEnabled = newValue
        }
    }
}
