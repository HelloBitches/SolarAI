import Foundation
import UIKit

/// Manages WiFi connection to the inverter's hotspot.
/// Since NEHotspotConfiguration requires a paid developer account,
/// this implementation guides the user to manually connect via iOS Settings,
/// then verifies connectivity by pinging the device API.
final class WiFiManager {

    static let shared = WiFiManager()

    private init() {}

    // MARK: - Connect (Manual Flow)

    /// Guide user to connect WiFi manually, then verify the connection by pinging the device.
    /// - Parameters:
    ///   - ssid: The WiFi SSID to display to the user
    ///   - password: The WiFi password to display to the user
    ///   - from: The presenting view controller (for showing the alert)
    ///   - completion: Called with success/failure on the main thread
    func connect(
        ssid: String,
        password: String,
        from viewController: UIViewController,
        completion: @escaping (Result<Void, WiFiError>) -> Void
    ) {
        let message = "Please connect to the WiFi manually:\n\n"
            + "1. Open iPhone Settings → WiFi\n"
            + "2. Find and connect to: \(ssid)\n"
            + "3. Password: \(password)\n"
            + "4. Come back to this app and tap \"Done\""

        let alert = UIAlertController(title: "Connect to Device WiFi", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: "App-Prefs:root=WIFI") {
                UIApplication.shared.open(url)
            } else if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })

        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            self.verifyDeviceReachable { reachable in
                if reachable {
                    completion(.success(()))
                } else {
                    completion(.failure(.verificationFailed))
                }
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(.failure(.userDenied))
        })

        viewController.present(alert, animated: true)
    }

    // MARK: - Disconnect

    func disconnect(ssid: String) {
        // Manual disconnect — user handles this in Settings
    }

    // MARK: - Verify Connection

    /// Ping the device's general.do endpoint to verify we're on the correct network
    func verifyDeviceReachable(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(AppConfig.baseURL)\(APIEndpoint.general)") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode),
                   data != nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }
}

// MARK: - WiFi Error

enum WiFiError: Error, LocalizedError {
    case connectionFailed(String)
    case userDenied
    case verificationFailed

    var errorDescription: String? {
        switch self {
        case .connectionFailed(let message): return "WiFi connection failed: \(message)"
        case .userDenied: return "Connection cancelled"
        case .verificationFailed: return "Cannot reach the inverter device. Please make sure you are connected to the correct WiFi."
        }
    }
}
