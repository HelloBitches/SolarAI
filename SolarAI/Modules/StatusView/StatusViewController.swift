import UIKit

/// Status View tab — shows the energy flow diagram with real-time data labels
final class StatusViewController: UIViewController {

    // MARK: - Properties

    private let viewModel = StatusViewModel()

    // MARK: - UI Elements

    private let energyFlowView = EnergyFlowView()

    // PV data labels
    private let pvChargerPLabel = DataLabel(prefix: "PV Charger P:")
    private let pvVoltLabel = DataLabel(prefix: "PV Volt:")
    private let pvChargerCurLabel = DataLabel(prefix: "PV Charger Cur:")

    // Inverter data labels
    private let invertVoltLabel = DataLabel(prefix: "Invert Volt:")
    private let invertCurLabel = DataLabel(prefix: "Invert Cur:")

    // Grid data labels
    private let gridPLabel = DataLabel(prefix: "Grid P:")
    private let gridCurLabel = DataLabel(prefix: "Grid Cur:")
    private let gridVoltLabel = DataLabel(prefix: "Grid Volt:")

    // Load data labels
    private let sloadLabel = DataLabel(prefix: "SLoad:")
    private let ploadLabel = DataLabel(prefix: "PLoad:")
    private let totalLabel = DataLabel(prefix: "Total:")

    // Battery data labels
    private let battVoltLabel = DataLabel(prefix: "Batt Volt:")
    private let battSOCLabel = DataLabel(prefix: "Batt SOC:")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupUI()
        viewModel.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startPolling()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopPolling()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.addSubview(energyFlowView)
        energyFlowView.translatesAutoresizingMaskIntoConstraints = false

        // Center the energy flow diagram
        NSLayoutConstraint.activate([
            energyFlowView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            energyFlowView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            energyFlowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            energyFlowView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.65),
        ])

        // PV labels — top right area (near solar panel)
        let pvStack = createVerticalStack([pvChargerPLabel, pvVoltLabel, pvChargerCurLabel])
        view.addSubview(pvStack)
        pvStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pvStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            pvStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
        ])

        // Inverter labels — middle right
        let inverterStack = createVerticalStack([invertVoltLabel, invertCurLabel])
        view.addSubview(inverterStack)
        inverterStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inverterStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            inverterStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
        ])

        // Grid labels — bottom right
        let gridStack = createVerticalStack([gridPLabel, gridCurLabel, gridVoltLabel])
        view.addSubview(gridStack)
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gridStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            gridStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
        ])

        // Load labels — bottom center
        let loadStack = createVerticalStack([sloadLabel, ploadLabel, totalLabel])
        view.addSubview(loadStack)
        loadStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            loadStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
        ])

        // Battery labels — bottom left
        let battStack = createVerticalStack([battVoltLabel, battSOCLabel])
        view.addSubview(battStack)
        battStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            battStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30),
            battStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
        ])

        setDefaultValues()
    }

    private func createVerticalStack(_ views: [UIView]) -> UIStackView {
        let sv = UIStackView(arrangedSubviews: views)
        sv.axis = .vertical
        sv.spacing = 2
        sv.alignment = .leading
        return sv
    }

    private func setDefaultValues() {
        pvChargerPLabel.setValue("0 W")
        pvVoltLabel.setValue("0.0 V")
        pvChargerCurLabel.setValue("0.0 A")
        invertVoltLabel.setValue("0.0 V")
        invertCurLabel.setValue("0.0 A")
        gridPLabel.setValue("0 W")
        gridCurLabel.setValue("0.0 A")
        gridVoltLabel.setValue("0.0 V")
        sloadLabel.setValue("0 VA")
        ploadLabel.setValue("0 W")
        totalLabel.setValue("0.0 kwh")
        battVoltLabel.setValue("0.0 V")
        battSOCLabel.setValue("0 %")
    }

    private func updateDataLabels(_ status: DeviceStatusResponse) {
        pvChargerPLabel.setValue(status.pvChargerPwrDisplay)
        pvVoltLabel.setValue(status.pvVoltDisplay)
        pvChargerCurLabel.setValue(status.pvChargerCurDisplay)
        invertVoltLabel.setValue(status.inverterVoltDisplay)
        invertCurLabel.setValue(status.inverterCurDisplay)
        gridPLabel.setValue(status.pgridDisplay)
        gridCurLabel.setValue(status.gridCurDisplay)
        gridVoltLabel.setValue(status.gridVoltDisplay)
        sloadLabel.setValue(status.sloadDisplay)
        ploadLabel.setValue(status.ploadDisplay)
        totalLabel.setValue(status.totalKwhDisplay)
        battVoltLabel.setValue(status.battVoltDisplay)

        battSOCLabel.isHidden = !status.shouldShowBattSOC
        if status.shouldShowBattSOC {
            battSOCLabel.setValue(status.bmsSocDisplay)
        }
    }
}

// MARK: - StatusViewModelDelegate

extension StatusViewController: StatusViewModelDelegate {

    func statusViewModelDidUpdateStatus(_ viewModel: StatusViewModel) {
        guard let status = viewModel.deviceStatus else { return }
        updateDataLabels(status)
    }

    func statusViewModelDidUpdateFlow(_ viewModel: StatusViewModel, flowType: EnergyFlowType) {
        energyFlowView.updateFlowType(flowType)
    }

    func statusViewModel(_ viewModel: StatusViewModel, didFailWithError error: String) {
        // Silently handle; will retry on next polling interval
    }
}

// MARK: - Data Label View

/// A small label showing "prefix value" in the status view
private final class DataLabel: UIView {

    private let label: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        l.textColor = AppColors.textPrimary
        return l
    }()

    private let prefix: String

    init(prefix: String) {
        self.prefix = prefix
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        self.prefix = ""
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.pinToSuperview()
    }

    func setValue(_ value: String) {
        label.text = "\(prefix) \(value)"
    }
}
