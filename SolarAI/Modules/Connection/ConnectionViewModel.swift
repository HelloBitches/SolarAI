import Foundation
import UIKit

protocol ConnectionViewModelDelegate: AnyObject {
    func didStartPinging()
    func didConnectSuccessfully()
    func didFailToConnect(error: String)
    func didUpdateStatus(_ message: String)
}

/// 登入页 ViewModel
///
/// 流程（参考 c019-app 模式）：
/// 1. 用户点「Refresh」→ 打开 iOS WiFi 设定
/// 2. 用户在设定中手动连接 SSE WiFi
/// 3. 返回 App → 侦测到网络变化 → 自动 Ping 设备
/// 4. Ping 成功 → 跳转主页
/// 5. Ping 失败 → 显示错误提示
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

    /// 重置状态（从主页返回时调用）
    func resetState() {
        hasNavigated = false
        isPinging = false
    }

    deinit {
        stopObserving()
    }

    // MARK: - 操作

    /// 打开系统 WiFi 设定
    func openWiFiSettings() {
        wifiManager.openWiFiSettings()
    }

    /// 手动触发连接（用户点击「Click to connect」）
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
