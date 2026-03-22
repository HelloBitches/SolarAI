import Foundation
import UIKit

protocol ConnectionViewModelDelegate: AnyObject {
    func didStartPinging()
    func didConnectSuccessfully()
    func didFailToConnect(error: String)
    func didUpdateStatus(_ message: String)
}

/// 登录页 ViewModel
///
/// 连接流程：
/// 1. 用户点 "Refresh the BT List" → 跳转 iOS WiFi 设置
/// 2. 用户手动连接 SSE 开头的 WiFi 热点 → 返回 App
/// 3. App 通过 WiFiManager 监听到网络变化 → 自动 Ping 设备（/general.do）
/// 4. Ping 成功 → hasNavigated=true → 通知 VC 跳转主页
/// 5. Ping 失败 → 显示红色错误提示
///
/// 特殊逻辑：
/// - 从主页退出返回登录页时，不会自动 Ping（防止立即跳回主页）
/// - App 从后台恢复前台时（appWillEnterForeground），会自动 Ping
/// - 用户可随时手动点击 "Click to connect" 触发 Ping
final class ConnectionViewModel {

    weak var delegate: ConnectionViewModelDelegate?

    private let wifiManager = WiFiManager.shared
    private var isPinging = false
    /// 防止重复跳转的标记
    private(set) var hasNavigated = false

    /// 防抖计时器，避免网络变化时连续多次 Ping
    private var pingDebounceTimer: Timer?

    // MARK: - 生命周期

    func startObserving() {
        wifiManager.startMonitoringNetworkChanges()
        NotificationCenter.default.addObserver(
            self, selector: #selector(onNetworkChanged),
            name: .networkDidChange, object: nil
        )
    }

    func stopObserving() {
        wifiManager.stopMonitoringNetworkChanges()
        NotificationCenter.default.removeObserver(self)
        pingDebounceTimer?.invalidate()
    }

    /// 重置状态（从主页 pop 返回时由 viewWillAppear 调用）
    /// 清除 hasNavigated 标记，允许后续再次跳转
    func resetState() {
        hasNavigated = false
        isPinging = false
    }

    deinit {
        stopObserving()
    }

    // MARK: - 操作

    /// 打开系统 WiFi 设置
    func openWiFiSettings() {
        wifiManager.openWiFiSettings()
    }

    /// 手动触发连接（用户点击"Click to connect"）
    func connectManually() {
        guard !hasNavigated else { return }
        guard wifiManager.isOnWiFi else {
            delegate?.didFailToConnect(error: WiFiError.notOnWiFi.localizedDescription)
            return
        }
        pingDevice()
    }

    /// App 从背景回到前景时调用
    func appDidBecomeActive() {
        guard !hasNavigated else { return }
        schedulePing()
    }

    // MARK: - 内部方法

    @objc private func onNetworkChanged() {
        guard !hasNavigated else { return }
        schedulePing()
    }

    /// 防抖 Ping，避免短时间内多次触发
    private func schedulePing() {
        pingDebounceTimer?.invalidate()
        pingDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { [weak self] _ in
            self?.pingDevice()
        }
    }

    private func pingDevice() {
        guard !isPinging, !hasNavigated else { return }
        guard wifiManager.isOnWiFi else { return }

        isPinging = true
        delegate?.didStartPinging()
        delegate?.didUpdateStatus("Wifi connecting")

        wifiManager.pingDevice { [weak self] reachable in
            guard let self = self else { return }
            self.isPinging = false

            if reachable && !self.hasNavigated {
                self.hasNavigated = true
                self.delegate?.didUpdateStatus("Device connecting")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.delegate?.didConnectSuccessfully()
                }
            } else if !reachable {
                self.delegate?.didFailToConnect(
                    error: WiFiError.deviceUnreachable.localizedDescription
                )
            }
        }
    }
}
