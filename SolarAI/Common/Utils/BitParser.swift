import Foundation

/// 用于将 16 位元旗标值解析为个别位元状态的工具
enum BitParser {

    /// 检查 16 位元值中特定位元是否被设定（位元 0 = 最右侧）
    static func isBitSet(_ value: Int, bit: Int) -> Bool {
        guard bit >= 0 && bit < 16 else { return false }
        return (value >> bit) & 1 == 1
    }

    /// 从 16 位元值获取所有已设定位元的位置
    static func getSetBits(_ value: Int) -> [Int] {
        var result: [Int] = []
        for bit in 0..<16 {
            if isBitSet(value, bit: bit) {
                result.append(bit)
            }
        }
        return result
    }

    // MARK: - 箭头旗标 → 能量流向类型

    /// 箭头旗标位元定义：
    ///   bit 1: 太阳能输入启用
    ///   bit 2: 电网/交流输入启用
    ///   bit 3: 电池放电中
    ///   bit 5: 电池充电中
    ///   bit 7: 负载输出启用
    static func parseArrowFlag(_ flag: Int) -> EnergyFlowType {
        let pvActive   = isBitSet(flag, bit: 1)
        let gridActive = isBitSet(flag, bit: 2)
        let battDischarging = isBitSet(flag, bit: 3)
        let battCharging    = isBitSet(flag, bit: 5)
        let loadActive      = isBitSet(flag, bit: 7)

        if pvActive && gridActive && loadActive && battCharging {
            return .pvGridToLoadBatt
        }
        if pvActive && battDischarging && loadActive {
            return .pvBattToLoad
        }
        if pvActive && loadActive && battCharging {
            return .pvToLoadBatt
        }
        if pvActive && loadActive {
            return .pvToLoad
        }
        if pvActive && battCharging {
            return .pvToBatt
        }
        if gridActive && loadActive && battCharging {
            return .gridToLoadBatt
        }
        if gridActive && loadActive {
            return .gridToLoad
        }
        if gridActive && battCharging {
            return .gridToBatt
        }
        if battDischarging && loadActive {
            return .battToLoad
        }

        return .noConnect
    }

    // MARK: - 硬件状态旗标

    /// 解析状态值以判断哪些硬件模组为启用状态
    static func parseHardwareStatus(_ value: Int) -> Set<Int> {
        var activeModules = Set<Int>()
        for bit in 0..<16 {
            if isBitSet(value, bit: bit) {
                activeModules.insert(bit)
            }
        }
        return activeModules
    }

    // MARK: - SINT 转换（用于 pgrid）

    /// 使用二补数将无符号 16 位元值转换为有符号
    static func toSigned16(_ value: Int) -> Int {
        if value <= 0 {
            return value
        }
        let inverted = (~value) & 0xFFFF
        return -(inverted + 1)
    }
}
