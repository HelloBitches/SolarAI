import Foundation
import UIKit
import SystemConfiguration
import Alamofire

/// 网络变化通知（WiFi 切换等）
extension Notification.Name {
    static let networkDidChange = Notification.Name("SolarAI.networkDidChange")
    static let deviceReachabilityResult = Notification.Name("SolarAI.deviceReachabilityResult")
}

/// WiFi 连接管理器
/// iOS 无法扫描 WiFi 列表，因此本类的职责是：
/// 1. 打开系统 WiFi 设定让用户手动连接
/// 2. 通过 SCNetworkReachability 监听网络变化
/// 3. 通过 Ping 设备 API 验证是否连接到正确的 WiFi
final class WiFiManager {

    static let shared = WiFiManager()

    private var reachability: SCNetworkReachability?
    private var isMonitoring = false

    private init() {}

    // MARK: - 打开系统 WiFi 设定

    func openWiFiSettings() {
        if let url = URL(string: "App-Prefs:root=WIFI"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - 网络变化监听

    func startMonitoringNetworkChanges() {
        guard !isMonitoring else { return }

        let host = "192.168.4.1"
        reachability = SCNetworkReachabilityCreateWithName(nil, host)

        var context = SCNetworkReachabilityContext(
            version: 0, info: nil, retain: nil, release: nil, copyDescription: nil
        )

        if let reachability = reachability {
            SCNetworkReachabilitySetCallback(reachability, { (_, _, _) in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .networkDidChange, object: nil)
                }
            }, &context)

            SCNetworkReachabilityScheduleWithRunLoop(
                reachability, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue
            )
        }

        // Darwin 系统级网络变化通知（与 c019-app 相同做法）
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            { (_, _, _, _, _) in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .networkDidChange, object: nil)
                }
            },
            "com.apple.system.config.network_change" as CFString,
            nil,
            .deliverImmediately
        )

        isMonitoring = true
    }

    func stopMonitoringNetworkChanges() {
        if let reachability = reachability {
            SCNetworkReachabilityUnscheduleFromRunLoop(
                reachability, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue
            )
        }
        reachability = nil
        isMonitoring = false
    }

    // MARK: - 判断是否在 WiFi 网络

    var isOnWiFi: Bool {
        let manager = NetworkReachabilityManager()
        return manager?.isReachableOnEthernetOrWiFi ?? false
    }

    // MARK: - Ping 设备验证连接

    /// 向逆变器 API 发送请求，验证是否连到正确的 WiFi
    func pingDevice(completion: ((Bool) -> Void)? = nil) {
        let url = "\(AppConfig.baseURL)\(APIEndpoint.general)"

        AF.request(url, method: .get, requestModifier: { $0.timeoutInterval = 4 })
            .validate(statusCode: 200..<300)
            .responseData { response in
                let success = response.data != nil && response.error == nil
                NotificationCenter.default.post(
                    name: .deviceReachabilityResult,
                    object: nil,
                    userInfo: ["reachable": success]
                )
                completion?(success)
            }
    }
}

// MARK: - WiFi 错误类型

enum WiFiError: Error, LocalizedError {
    case notOnWiFi
    case deviceUnreachable
    case cancelled

    var errorDescription: String? {
        switch self {
        case .notOnWiFi:
            return "请先连接到 WiFi 网络"
        case .deviceUnreachable:
            return "Unable to connect to inverter, please confirm you are connected to SSE WiFi"
        case .cancelled:
            return "连接已取消"
        }
    }
}
