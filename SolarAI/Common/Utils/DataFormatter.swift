import Foundation

/// 将 /devStatus.do 返回的原始整数值格式化为 UI 显示字符串
///
/// 协议要求：
/// - 电压/电流类字段（pv1_volt, grid_volt, batt_volt, grid_cur, inverter_volt, inverter_cur）需 ÷ 10.0
/// - 功率类字段（pv1_charger_pwr, pload）直接显示
/// - pgrid 特殊处理：> 0 时做 SINT16 转换
/// - Total kWh = pwr_total_h_load * 1000 + pwr_total_l_load * 0.1
enum DataFormatter {

    /// 电压字段：原始值 ÷ 10.0，保留一位小数，单位 V
    static func formatVoltage(_ rawValue: Int) -> String {
        let value = Double(rawValue) / 10.0
        return String(format: "%.1f V", value)
    }

    /// 电流字段：原始值 ÷ 10.0，保留一位小数，单位 A
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

    /// 总用电量 kWh：由高低两个字段组合计算
    /// 公式：pwr_total_h_load * 1000 + pwr_total_l_load * 0.1
    static func formatTotalKwh(high: Int, low: Int) -> String {
        let total = Double(high) * 1000.0 + Double(low) * 0.1
        return String(format: "%.1f kwh", total)
    }

    /// 电网功率 pgrid：≤0 直接显示；>0 时做 SINT16 二补数转换后显示
    /// 协议原文："上传数据小于等于0直接显示，大于0时采用SINT解析后显示"
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
