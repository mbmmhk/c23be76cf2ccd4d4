import Foundation

class CryptoFormatter {
    static let shared = CryptoFormatter()

    private let locale = Locale(identifier: "en_US")

    private init() {}

    /// Formats a cryptocurrency value to a fixed number of fractional digits (e.g., 8 for BTC)
    func format(value: Decimal, decimalPlaces: Int = 8) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = decimalPlaces
        formatter.minimumFractionDigits = decimalPlaces

        return formatter.string(from: value as NSDecimalNumber) ?? "--"
    }

    /// Parses a string to a Decimal value
    func parse(value: String) -> Decimal? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        return formatter.number(from: value)?.decimalValue
    }
}
