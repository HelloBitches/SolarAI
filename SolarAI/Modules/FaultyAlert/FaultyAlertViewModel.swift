import Foundation

protocol FaultyAlertViewModelDelegate: AnyObject {
    func faultyAlertViewModelDidUpdate(_ viewModel: FaultyAlertViewModel)
    func faultyAlertViewModel(_ viewModel: FaultyAlertViewModel, didFailWithError error: String)
}

/// ViewModel for the Faulty Alert tab — fetches and parses error/warning bit fields
final class FaultyAlertViewModel {

    weak var delegate: FaultyAlertViewModelDelegate?

    private(set) var faultItems: [FaultItem] = []
    private(set) var isLoading = false

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
        isLoading = true
        NetworkService.shared.fetchFaultyAlert { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
                self.faultItems = response.parseAllAlerts()
                self.delegate?.faultyAlertViewModelDidUpdate(self)
            case .failure(let error):
                self.delegate?.faultyAlertViewModel(self, didFailWithError: error.localizedDescription)
            }
        }
    }
}
