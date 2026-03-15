import Foundation

/// 将原始设备资料值格式化为可显示的字串
enum DataFormatter {

    /// 除以 10.0 并格式化为电压
    static func formatVoltage(_ rawValue: Int) -> String {
        let value = Double(rawValue) / 10.0
        return String(format: "%.1f V", value)
    }

    /// 除以 10.0 并格式化为电流
    static func formatCurrent(_ rawValue: Int) -> String {
        let value = Double(rawValue) / 10.0
        return String(format: "%.1f A", value)
    }

    /// 以瓦特格式化功率
    static func formatPower(_ rawValue: Int) -> String {
        return "\(rawValue) W"
    }

    /// 以 VA 格式化视在功率
    static func formatVA(_ rawValue: Int) -> String {
        return "\(rawValue) VA"
    }

    /// 从高位元组与低位元组值计算总 kWh
    /// 公式：high * 1000 + low * 0.1
    static func formatTotalKwh(high: Int, low: Int) -> String {
        let total = Double(high) * 1000.0 + Double(low) * 0.1
        return String(format: "%.1f kwh", total)
    }

    /// 解析电网功率 (pgrid)，正值时考虑 SINT 转换
    static func formatGridPower(_ rawValue: Int) -> String {
        let displayValue: Int
        if rawValue <= 0 {
            displayValue = rawValue
        } else {
            displayValue = BitParser.toSigned16(rawValue)
        }
        return "\(displayValue) W"
    }

    /// 格式化电池 SOC 百分比
    static func formatSOC(_ rawValue: Int) -> String {
        return "\(rawValue) %"
    }
}
