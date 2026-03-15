import Foundation

/// Formats raw device data values into display-ready strings
enum DataFormatter {

    /// Divide by 10.0 and format as voltage
    static func formatVoltage(_ rawValue: Int) -> String {
        let value = Double(rawValue) / 10.0
        return String(format: "%.1f V", value)
    }

    /// Divide by 10.0 and format as current
    static func formatCurrent(_ rawValue: Int) -> String {
        let value = Double(rawValue) / 10.0
        return String(format: "%.1f A", value)
    }

    /// Format power in watts
    static func formatPower(_ rawValue: Int) -> String {
        return "\(rawValue) W"
    }

    /// Format apparent power in VA
    static func formatVA(_ rawValue: Int) -> String {
        return "\(rawValue) VA"
    }

    /// Calculate total kWh from high and low word values
    /// Formula: high * 1000 + low * 0.1
    static func formatTotalKwh(high: Int, low: Int) -> String {
        let total = Double(high) * 1000.0 + Double(low) * 0.1
        return String(format: "%.1f kwh", total)
    }

    /// Parse grid power (pgrid) considering SINT for positive values
    static func formatGridPower(_ rawValue: Int) -> String {
        let displayValue: Int
        if rawValue <= 0 {
            displayValue = rawValue
        } else {
            displayValue = BitParser.toSigned16(rawValue)
        }
        return "\(displayValue) W"
    }

    /// Format battery SOC percentage
    static func formatSOC(_ rawValue: Int) -> String {
        return "\(rawValue) %"
    }
}
