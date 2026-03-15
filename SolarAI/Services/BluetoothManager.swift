import Foundation
import CoreBluetooth

protocol BluetoothManagerDelegate: AnyObject {
    func bluetoothManager(_ manager: BluetoothManager, didDiscoverDevice device: BluetoothDevice)
    func bluetoothManager(_ manager: BluetoothManager, didUpdateState state: CBManagerState)
    func bluetoothManager(_ manager: BluetoothManager, didFailWithError error: Error)
}

/// Represents a discovered BLE device (the solar inverter)
struct BluetoothDevice {
    let name: String
    let peripheral: CBPeripheral
    let rssi: Int

    /// The device name is also used as the WiFi SSID
    var wifiSSID: String { name }
}

/// Manages CoreBluetooth scanning to discover inverter devices
final class BluetoothManager: NSObject {

    static let shared = BluetoothManager()

    weak var delegate: BluetoothManagerDelegate?

    private var centralManager: CBCentralManager?
    private(set) var discoveredDevices: [BluetoothDevice] = []
    private(set) var isScanning = false

    private override init() {
        super.init()
    }

    // MARK: - Public

    func startScanning() {
        discoveredDevices.removeAll()

        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: .main)
        } else if centralManager?.state == .poweredOn {
            beginScan()
        }
    }

    func stopScanning() {
        centralManager?.stopScan()
        isScanning = false
    }

    // MARK: - Private

    private func beginScan() {
        guard centralManager?.state == .poweredOn else { return }
        isScanning = true
        centralManager?.scanForPeripherals(withServices: nil, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ])

        // Auto-stop scanning after 15 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self] in
            self?.stopScanning()
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension BluetoothManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.bluetoothManager(self, didUpdateState: central.state)

        if central.state == .poweredOn {
            beginScan()
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        guard let name = peripheral.name, !name.isEmpty else { return }

        // Avoid duplicates
        if discoveredDevices.contains(where: { $0.peripheral.identifier == peripheral.identifier }) {
            return
        }

        let device = BluetoothDevice(name: name, peripheral: peripheral, rssi: RSSI.intValue)
        discoveredDevices.append(device)
        delegate?.bluetoothManager(self, didDiscoverDevice: device)
    }
}
