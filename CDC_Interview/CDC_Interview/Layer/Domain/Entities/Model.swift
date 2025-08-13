import Foundation

enum Tag: String, Decodable {
    case deposit = "deposit"
    case withdrawal = "withdrawal"
}

struct USDPrice: Decodable {
    struct Price: Decodable, Identifiable {
        let id: Int
        let name: String
        let usd: Decimal
        let tags: [Tag]
    }

    let data: [Price]
}

struct AllPrice: Decodable {
    struct Price: Decodable, Identifiable {
        struct PriceRecord: Decodable {
            let usd: Decimal
            let eur: Decimal
        }
        
        let id: Int
        let name: String
        let price: PriceRecord
        let tags: [Tag]
    }

    let data: [Price]
}
