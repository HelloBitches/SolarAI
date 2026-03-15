import Foundation

/// Utility for parsing 16-bit flag values into individual bit states
enum BitParser {

    /// Check if a specific bit is set in a 16-bit value (bit 0 = rightmost)
    static func isBitSet(_ value: Int, bit: Int) -> Bool {
        guard bit >= 0 && bit < 16 else { return false }
        return (value >> bit) & 1 == 1
    }

    /// Get all set bit positions from a 16-bit value
    static func getSetBits(_ value: Int) -> [Int] {
        var result: [Int] = []
        for bit in 0..<16 {
            if isBitSet(value, bit: bit) {
                result.append(bit)
            }
        }
        return result
    }

    // MARK: - Arrow Flag → Energy Flow Type

    /// Arrow flag bit definitions:
    ///   bit 1: PV input active
    ///   bit 2: Grid/AC input active
    ///   bit 3: Battery discharging
    ///   bit 5: Battery charging
    ///   bit 7: Load output active
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

    // MARK: - Hardware Status Flag

    /// Parse the status value to determine which hardware modules are active
    static func parseHardwareStatus(_ value: Int) -> Set<Int> {
        var activeModules = Set<Int>()
        for bit in 0..<16 {
            if isBitSet(value, bit: bit) {
                activeModules.insert(bit)
            }
        }
        return activeModules
    }

    // MARK: - SINT Conversion (for pgrid)

    /// Convert unsigned 16-bit value to signed using two's complement
    static func toSigned16(_ value: Int) -> Int {
        if value <= 0 {
            return value
        }
        let inverted = (~value) & 0xFFFF
        return -(inverted + 1)
    }
}
