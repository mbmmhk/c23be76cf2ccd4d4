import Foundation

/// A thread-safe formatter for cryptocurrency prices and values
/// Provides intelligent precision control and multi-currency support
final class CryptoFormatter {
    static let shared = CryptoFormatter()

    // MARK: - Thread Safety
    /// Serial queue to ensure thread-safe formatter operations
    private let formatterQueue = DispatchQueue(label: "CryptoFormatter.queue", qos: .userInitiated)

    // MARK: - Cached Formatters
    /// Cached USD formatter for optimal performance
    private lazy var usdFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        formatter.roundingMode = .down // Consistent with financial standards
        return formatter
    }()

    /// Cached EUR formatter for optimal performance
    private lazy var eurFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "en_EU")
        formatter.roundingMode = .down
        return formatter
    }()

    /// Cached decimal formatter for non-currency values
    private lazy var decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US")
        formatter.roundingMode = .down
        return formatter
    }()

    private init() {}

    // MARK: - Currency Types
    /// Supported currency types for formatting
    enum CurrencyType {
        case usd
        case eur

        var code: String {
            switch self {
            case .usd: return "USD"
            case .eur: return "EUR"
            }
        }

        var locale: Locale {
            switch self {
            case .usd: return Locale(identifier: "en_US")
            case .eur: return Locale(identifier: "en_EU")
            }
        }

        var fallback: String {
            switch self {
            case .usd: return "$0.00"
            case .eur: return "€0.00"
            }
        }
    }

    // MARK: - Smart USD Formatting
    /// Formats USD values with intelligent precision control
    /// - Parameter value: The decimal value to format
    /// - Returns: Formatted USD string with appropriate precision
    func formatUSD(_ value: Decimal) -> String {
        return formatterQueue.sync {
            // Intelligent precision based on value magnitude
            if value >= 1.0 {
                usdFormatter.minimumFractionDigits = 2
                usdFormatter.maximumFractionDigits = 2
            } else if value >= 0.01 {
                usdFormatter.minimumFractionDigits = 2
                usdFormatter.maximumFractionDigits = 4
            } else {
                usdFormatter.minimumFractionDigits = 2
                usdFormatter.maximumFractionDigits = 8 // High precision for small crypto values
            }
            return usdFormatter.string(from: value as NSDecimalNumber) ?? CurrencyType.usd.fallback
        }
    }

    // MARK: - Smart EUR Formatting
    /// Formats EUR values with intelligent precision control
    /// - Parameter value: The decimal value to format
    /// - Returns: Formatted EUR string with appropriate precision
    func formatEUR(_ value: Decimal) -> String {
        return formatterQueue.sync {
            // Intelligent precision based on value magnitude
            if value >= 1.0 {
                eurFormatter.minimumFractionDigits = 2
                eurFormatter.maximumFractionDigits = 2
            } else if value >= 0.01 {
                eurFormatter.minimumFractionDigits = 2
                eurFormatter.maximumFractionDigits = 4
            } else {
                eurFormatter.minimumFractionDigits = 2
                eurFormatter.maximumFractionDigits = 8 // High precision for small crypto values
            }
            return eurFormatter.string(from: value as NSDecimalNumber) ?? CurrencyType.eur.fallback
        }
    }

    // MARK: - Generic Currency Formatting
    /// Formats a value using the specified currency type
    /// - Parameters:
    ///   - value: The decimal value to format
    ///   - currency: The currency type to use
    /// - Returns: Formatted currency string
    func format(_ value: Decimal, currency: CurrencyType) -> String {
        switch currency {
        case .usd: return formatUSD(value)
        case .eur: return formatEUR(value)
        }
    }

    // MARK: - Decimal Formatting
    /// Formats a cryptocurrency value to a fixed number of fractional digits
    /// - Parameters:
    ///   - value: The decimal value to format
    ///   - decimalPlaces: Number of decimal places (default: 8)
    /// - Returns: Formatted decimal string
    func format(value: Decimal, decimalPlaces: Int = 8) -> String {
        return formatterQueue.sync {
            decimalFormatter.maximumFractionDigits = decimalPlaces
            decimalFormatter.minimumFractionDigits = decimalPlaces
            return decimalFormatter.string(from: value as NSDecimalNumber) ?? "--"
        }
    }

    // MARK: - Parsing
    /// Parses a string to a Decimal value
    /// - Parameter value: The string to parse
    /// - Returns: Parsed decimal value or nil if parsing fails
    func parse(value: String) -> Decimal? {
        return formatterQueue.sync {
            decimalFormatter.numberStyle = .decimal
            return decimalFormatter.number(from: value)?.decimalValue
        }
    }
}

// MARK: - Protocol Support
/// Protocol for types that can be formatted by CryptoFormatter
protocol CryptoFormattable {}

extension Decimal: CryptoFormattable {}
extension Double: CryptoFormattable {}
extension Float: CryptoFormattable {}
extension Int: CryptoFormattable {}
