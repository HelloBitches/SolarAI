import Foundation

protocol FaultyAlertViewModelDelegate: AnyObject {
    func faultyAlertViewModelDidUpdate(_ viewModel: FaultyAlertViewModel)
    func faultyAlertViewModel(_ viewModel: FaultyAlertViewModel, didFailWithError error: String)
}

/// Faulty Alert 标签页的 ViewModel
///
/// 职责：
/// 1. 定时轮询 /faultyAlert.do
/// 2. 将 error1~3、warn1~2、pv1_charger_error、pv1_charger_warn 的每一位
///    与 ErrorDefinitions 中的故障码定义匹配，生成 FaultItem 列表
/// 3. 通知 ViewController 更新三列表格显示
final class FaultyAlertViewModel {

    weak var delegate: FaultyAlertViewModelDelegate?

    private(set) var faultItems: [FaultItem] = []
    private(set) var isLoading = false

    private var refreshTimer: Timer?

    // MARK: - 公开方法

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

    // MARK: - 私有方法

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
