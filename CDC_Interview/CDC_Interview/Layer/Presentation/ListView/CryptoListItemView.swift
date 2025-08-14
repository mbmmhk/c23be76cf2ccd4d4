//
//  CryptoListItemView.swift
//  CDC_Interview
//
//  Created by Junjie Gu on 2025/8/14.
//

import Foundation
import SwiftUI

struct CryptoListItemView: View {
    let displayItem: CryptoListViewModel.DisplayItem

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(displayItem.name)
                    .font(.headline)
            }

            HStack {
                Text("USD: \(displayItem.usdPrice)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let eurPrice = displayItem.eurPrice, displayItem.showEUR {
                    Spacer()
                    Text("EUR: \(eurPrice)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            if !displayItem.tags.isEmpty {
                HStack {
                    ForEach(displayItem.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                    Spacer()
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview("USD Only") {
    CryptoListItemView(displayItem: CryptoListViewModel.DisplayItem(
        id: 1,
        name: "Bitcoin",
        symbol: "BTC",
        usdPrice: "$45,123.45",
        eurPrice: nil,
        tags: ["cryptocurrency", "digital-currency"],
        showEUR: false
    ))
    .padding()
}

#Preview("USD and EUR") {
    CryptoListItemView(displayItem: CryptoListViewModel.DisplayItem(
        id: 2,
        name: "Ethereum",
        symbol: "ETH",
        usdPrice: "$2,845.67",
        eurPrice: "€2,634.12",
        tags: ["cryptocurrency", "smart-contracts", "defi"],
        showEUR: true
    ))
    .padding()
}

#Preview("No Tags") {
    CryptoListItemView(displayItem: CryptoListViewModel.DisplayItem(
        id: 3,
        name: "Cardano",
        symbol: "ADA",
        usdPrice: "$0.45",
        eurPrice: "€0.42",
        tags: [],
        showEUR: true
    ))
    .padding()
}

#Preview("Multiple Items") {
    VStack(spacing: 8) {
        CryptoListItemView(displayItem: CryptoListViewModel.DisplayItem(
            id: 1,
            name: "Bitcoin",
            symbol: "BTC",
            usdPrice: "$45,123.45",
            eurPrice: "€41,789.23",
            tags: ["cryptocurrency", "store-of-value"],
            showEUR: true
        ))

        Divider()

        CryptoListItemView(displayItem: CryptoListViewModel.DisplayItem(
            id: 2,
            name: "Ethereum",
            symbol: "ETH",
            usdPrice: "$2,845.67",
            eurPrice: nil,
            tags: ["cryptocurrency", "smart-contracts"],
            showEUR: false
        ))

        Divider()

        CryptoListItemView(displayItem: CryptoListViewModel.DisplayItem(
            id: 3,
            name: "Solana",
            symbol: "SOL",
            usdPrice: "$89.12",
            eurPrice: "€82.45",
            tags: ["cryptocurrency", "fast-transactions", "web3"],
            showEUR: true
        ))
    }
    .padding()
}
