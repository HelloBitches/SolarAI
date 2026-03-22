import Foundation

/// GET /faultyAlert.do 的响应模型
///
/// 每个字段都是 16 位标志位，每一位对应一个故障/警告。
/// 调用 parseAllAlerts() 遍历所有字段的每一位，匹配 ErrorDefinitions 中的定义，
/// 生成 FaultItem 列表用于 Faulty Alert 页的三列表格展示。
struct FaultyAlertResponse: Codable {
    let status: Int
    let error1: Int
    let error2: Int
    let error3: Int
    let warn1: Int
    let warn2: Int
    let pv1ChargerError: Int
    let pv1ChargerWarn: Int

    enum CodingKeys: String, CodingKey {
        case status
        case error1
        case error2
        case error3
        case warn1
        case warn2
        case pv1ChargerError = "pv1_charger_error"
        case pv1ChargerWarn = "pv1_charger_warn"
    }

    /// 解析所有启用的故障/警告为可显示项目
    func parseAllAlerts() -> [FaultItem] {
        var items: [FaultItem] = []
        items.append(contentsOf: parseField(error1, definitions: ErrorDefinitions.error1))
        items.append(contentsOf: parseField(error2, definitions: ErrorDefinitions.error2))
        items.append(contentsOf: parseField(error3, definitions: ErrorDefinitions.error3))
        items.append(contentsOf: parseField(warn1, definitions: ErrorDefinitions.warn1))
        items.append(contentsOf: parseField(warn2, definitions: ErrorDefinitions.warn2))
        items.append(contentsOf: parseField(pv1ChargerError, definitions: ErrorDefinitions.chargerError))
        items.append(contentsOf: parseField(pv1ChargerWarn, definitions: ErrorDefinitions.chargerWarn))
        return items
    }

    private func parseField(_ value: Int, definitions: [Int: FaultDefinition]) -> [FaultItem] {
        var items: [FaultItem] = []
        for bit in 0..<16 where BitParser.isBitSet(value, bit: bit) {
            if let def = definitions[bit] {
                items.append(FaultItem(
                    code: def.code,
                    event: def.description,
                    solution: def.solution,
                    isWarning: def.isWarning
                ))
            }
        }
        return items
    }
}

/// 单一故障/警告显示项目
struct FaultItem {
    let code: String
    let event: String
    let solution: String
    let isWarning: Bool
}
