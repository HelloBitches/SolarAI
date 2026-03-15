import Foundation

protocol StatusViewModelDelegate: AnyObject {
    func statusViewModelDidUpdateStatus(_ viewModel: StatusViewModel)
    func statusViewModelDidUpdateFlow(_ viewModel: StatusViewModel, flowType: EnergyFlowType)
    func statusViewModel(_ viewModel: StatusViewModel, didFailWithError error: String)
}

/// ViewModel for the Status View tab — polls device status and general endpoints
final class StatusViewModel {

    weak var delegate: StatusViewModelDelegate?

    private(set) var deviceStatus: DeviceStatusResponse?
    private(set) var currentFlowType: EnergyFlowType = .noConnect

    private var refreshTimer: Timer?

    // MARK: - Public

    func startPolling() {
        fetchData()
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: AppConfig.dataRefreshInterval, repeats: true) { [weak self] _ in
            self?.fetchData()
        }
    }

    func stopPolling() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    // MARK: - Private

    private func fetchData() {
        let group = DispatchGroup()

        // Fetch arrow_flag for flow animation
        group.enter()
        NetworkService.shared.fetchGeneral { [weak self] result in
            if case .success(let response) = result {
                let flowType = BitParser.parseArrowFlag(response.arrowFlag)
                if self?.currentFlowType != flowType {
                    self?.currentFlowType = flowType
                    DispatchQueue.main.async {
                        self?.delegate?.statusViewModelDidUpdateFlow(self!, flowType: flowType)
                    }
                }
            }
            group.leave()
        }

        // Fetch device status for data labels
        group.enter()
        NetworkService.shared.fetchDeviceStatus { [weak self] result in
            switch result {
            case .success(let response):
                self?.deviceStatus = response
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.delegate?.statusViewModel(self!, didFailWithError: error.localizedDescription)
                }
            }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.delegate?.statusViewModelDidUpdateStatus(self)
        }
    }
}

// MARK: - Equatable for EnergyFlowType

extension EnergyFlowType: Equatable {}
