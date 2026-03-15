import Foundation
import UIKit

protocol ConnectionViewModelDelegate: AnyObject {
    func didStartConnecting()
    func didConnectSuccessfully(deviceName: String)
    func didFailToConnect(error: String)
}

/// ViewModel for the connection/login screen
final class ConnectionViewModel {

    weak var delegate: ConnectionViewModelDelegate?

    private let wifiManager = WiFiManager.shared

    private(set) var isConnecting = false

    // MARK: - Actions

    /// Open iPhone WiFi Settings so user can see available SSE... networks
    func openWiFiSettings() {
        if let url = URL(string: "App-Prefs:root=WIFI") {
            UIApplication.shared.open(url)
        } else if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    /// Connect to the specified WiFi SSID
    func connect(ssid: String, password: String, from viewController: UIViewController) {
        guard !ssid.isEmpty else {
            delegate?.didFailToConnect(error: "Please enter the WiFi name")
            return
        }

        isConnecting = true
        delegate?.didStartConnecting()

        wifiManager.connect(ssid: ssid, password: password, from: viewController) { [weak self] result in
            guard let self = self else { return }
            self.isConnecting = false

            switch result {
            case .success:
                self.delegate?.didConnectSuccessfully(deviceName: ssid)
            case .failure(let error):
                self.delegate?.didFailToConnect(error: error.localizedDescription)
            }
        }
    }
}
