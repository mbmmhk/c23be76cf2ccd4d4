import Foundation

// MARK: - Common Protocol

/// Protocol for cryptocurrency price items with common properties
protocol CryptoPriceItem {
    var id: Int { get }
    var name: String { get }
    var tags: [Tag] { get }
}

// MARK: - Tag Enumeration

enum Tag: String, Decodable, CaseIterable {
    case deposit
    case withdrawal
}

struct USDPrice: Decodable {
    struct Price: CryptoPriceItem, Decodable, Identifiable {
        let id: Int
        let name: String
        let usd: Decimal
        let tags: [Tag]

        // MARK: - Convenience Properties

        /// Tags as string array for display purposes
        var tagStrings: [String] {
            tags.map { $0.rawValue }
        }
    }

    let data: [Price]
}

struct AllPrice: Decodable {
    struct Price: CryptoPriceItem, Decodable, Identifiable {
        struct PriceRecord: Decodable {
            let usd: Decimal
            let eur: Decimal
        }

        let id: Int
        let name: String
        let price: PriceRecord
        let tags: [Tag]

        // MARK: - Convenience Properties

        /// Tags as string array for display purposes
        var tagStrings: [String] {
            tags.map { $0.rawValue }
        }

        /// Direct access to USD price for consistency with USDPrice.Price
        var usd: Decimal {
            price.usd
        }

        /// Direct access to EUR price
        var eur: Decimal {
            price.eur
        }
    }

    let data: [Price]
}
