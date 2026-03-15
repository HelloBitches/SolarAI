import UIKit

// MARK: - App Configuration

enum AppConfig {
    static let appName = "Solar AI Inverter Setup APP"
    static let appVersion = "V01R001B001"
    static let defaultPassword = "SSE123456"
    static let baseURL = "http://192.168.4.1:8080"
    static let dataRefreshInterval: TimeInterval = 3.0
}

// MARK: - API Endpoints

enum APIEndpoint {
    static let general = "/general.do"
    static let deviceStatus = "/devStatus.do"
    static let faultyAlert = "/faultyAlert.do"
    static let password = "/password.do"
    static let showInfo = "/showInfo.do"
}

// MARK: - Colors

enum AppColors {
    static let background = UIColor(hex: "#1a343d")
    static let accent = UIColor(hex: "#C56A02")
    static let accentGradientStart = UIColor(hex: "#FF8C00")
    static let accentGradientEnd = UIColor(hex: "#FFA500")
    static let error = UIColor(hex: "#FF4444")
    static let confirm = UIColor(hex: "#00BFA5")
    static let textPrimary = UIColor.white
    static let textSecondary = UIColor(white: 0.65, alpha: 1.0)
    static let separator = UIColor(white: 0.3, alpha: 1.0)
    static let cardBackground = UIColor(hex: "#1C2B3A")
    static let tabSelected = UIColor(hex: "#C56A02")
    static let tabNormal = UIColor(hex: "#2A3D4E")
    static let inputBackground = UIColor(hex: "#253545")
}

// MARK: - Hardware Icon Names

/// Maps hardware feature names to their icon asset names (gray/orange pairs)
enum HardwareIcon: Int, CaseIterable {
    case heartbeat = 0
    case bluetooth
    case wifi
    case fourG
    case gps
    case pvInput
    case battery
    case grid
    case load
    case generator
    case bts
    case rs485
    case usb
    case bms
    case can
    case ct

    var title: String {
        switch self {
        case .heartbeat:  return "Heartbeat"
        case .bluetooth:  return "Bluetooth"
        case .wifi:       return "WiFi"
        case .fourG:      return "4G"
        case .gps:        return "GPS"
        case .pvInput:    return "PV Input"
        case .battery:    return "Battery"
        case .grid:       return "Grid"
        case .load:       return "Load"
        case .generator:  return "Generator"
        case .bts:        return "BTS"
        case .rs485:      return "RS485"
        case .usb:        return "USB"
        case .bms:        return "BMS"
        case .can:        return "CAN"
        case .ct:         return "CT"
        }
    }

    var grayImageName: String {
        return "hw_gray_\(rawValue)"
    }

    var orangeImageName: String {
        return "hw_orange_\(rawValue)"
    }

    /// Bit position in the status flag (from right, 0-indexed)
    var statusBit: Int {
        return rawValue
    }
}

// MARK: - Flow Animation

/// Maps arrow_flag bit patterns to animation image set names
enum EnergyFlowType: String {
    case noConnect       = "no_connect"
    case battToLoad      = "b_inver_l"
    case gridToBatt      = "gr_inver_b"
    case gridToLoad      = "gr_inver_l"
    case gridToLoadBatt  = "gr_inver_l_b"
    case pvToBatt        = "pv_inver_b"
    case pvToLoad        = "pv_inver_l"
    case pvToLoadBatt    = "pv_inver_l_b"
    case pvBattToLoad    = "pvb_inver_l"
    case pvGridToLoadBatt = "pvgrid_inver_l_b"

    var frameCount: Int {
        return self == .noConnect ? 1 : 6
    }

    func frameImageName(at index: Int) -> String {
        if self == .noConnect {
            return rawValue
        }
        return "\(rawValue)\(index + 1)"
    }
}

// MARK: - Animation Duration

enum AnimationConfig {
    static let flowFrameDuration: TimeInterval = 0.5
    static let flowAnimationRepeat: Int = 0  // 0 = infinite
}
