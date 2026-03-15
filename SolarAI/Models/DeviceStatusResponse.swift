import Foundation

/// Response from GET /devStatus.do
struct DeviceStatusResponse: Codable {
    let status: Int
    let pv1Volt: Int             // ÷10 → PV Volt (V)
    let pv1ChargerCur: Int       // ÷10 → PV Charger Cur (A)
    let pv1ChargerPwr: Int       // PV Charger P (W)
    let battVolt: Int            // ÷10 → Batt Volt (V)
    let gridVolt: Int            // ÷10 → Grid Volt (V)
    let gridCur: Int             // ÷10 → Grid Cur (A)
    let sload: Int               // SLoad (VA)
    let pgrid: Int               // Grid P (W) — needs SINT conversion if > 0
    let pload: Int               // PLoad (W)
    let inverterVolt: Int        // ÷10 → Inverter Volt (V)
    let inverterCur: Int         // ÷10 → Inverter Cur (A)
    let bmsSocVal: Int           // Battery SOC (%)
    let battType: Int            // 2 = lithium (show SOC), else hide
    let pwrTotalHLoad: Int       // Total kWh high word
    let pwrTotalLLoad: Int       // Total kWh low word

    enum CodingKeys: String, CodingKey {
        case status
        case pv1Volt = "pv1_volt"
        case pv1ChargerCur = "pv1_charger_cur"
        case pv1ChargerPwr = "pv1_charger_pwr"
        case battVolt = "batt_volt"
        case gridVolt = "grid_volt"
        case gridCur = "grid_cur"
        case sload
        case pgrid
        case pload = "Pload"
        case inverterVolt = "inverter_volt"
        case inverterCur = "inverter_cur"
        case bmsSocVal = "bms_soc_val"
        case battType = "batt_type"
        case pwrTotalHLoad = "pwr_total_h_load"
        case pwrTotalLLoad = "pwr_total_l_load"
    }

    // MARK: - Formatted Display Values

    var pvVoltDisplay: String { DataFormatter.formatVoltage(pv1Volt) }
    var pvChargerCurDisplay: String { DataFormatter.formatCurrent(pv1ChargerCur) }
    var pvChargerPwrDisplay: String { DataFormatter.formatPower(pv1ChargerPwr) }
    var battVoltDisplay: String { DataFormatter.formatVoltage(battVolt) }
    var gridVoltDisplay: String { DataFormatter.formatVoltage(gridVolt) }
    var gridCurDisplay: String { DataFormatter.formatCurrent(gridCur) }
    var sloadDisplay: String { DataFormatter.formatVA(sload) }
    var pgridDisplay: String { DataFormatter.formatGridPower(pgrid) }
    var ploadDisplay: String { DataFormatter.formatPower(pload) }
    var inverterVoltDisplay: String { DataFormatter.formatVoltage(inverterVolt) }
    var inverterCurDisplay: String { DataFormatter.formatCurrent(inverterCur) }
    var bmsSocDisplay: String { DataFormatter.formatSOC(bmsSocVal) }
    var totalKwhDisplay: String { DataFormatter.formatTotalKwh(high: pwrTotalHLoad, low: pwrTotalLLoad) }
    var shouldShowBattSOC: Bool { battType == 2 }
}
