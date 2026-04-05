import Foundation

protocol PaygoViewModelDelegate: AnyObject {
    func paygoViewModelDidSubmitSuccess(_ viewModel: PaygoViewModel)
    func paygoViewModel(_ viewModel: PaygoViewModel, didSubmitFailure message: String)
    func paygoViewModel(_ viewModel: PaygoViewModel, didUpdateInfo info: String)
    func paygoViewModel(_ viewModel: PaygoViewModel, didGetBlocked remainingSeconds: Int)
}

/// PAYGO 标签页的 ViewModel
///
/// 职责：
/// 1. 管理用户输入的解锁码（appendDigit / deleteLastDigit / clearCode）
/// 2. 提交解锁码到 /password.do，处理三种响应状态（成功/失败/锁定）
/// 3. 定时轮询 /showInfo.do 获取设备实时状态文本
/// 4. 提交完成后立即刷新 info（不等待下次轮询）
/// 5. Compatibility 开关控制请求字段名（pwd / code）
final class PaygoViewModel {

    weak var delegate: PaygoViewModelDelegate?

    private(set) var currentCode: String = ""
    private(set) var useCompatibility: Bool = false
    private(set) var deviceInfo: String = "Input code"

    private var infoTimer: Timer?

    /// 数字键盘追加结果（禁用 7、8、9、0）
    enum AppendDigitResult {
        case appended
        case maxLengthReached
        case forbiddenDigit
    }

    // MARK: - 代码输入

    func appendDigit(_ digit: Int) -> AppendDigitResult {
        if digit == 0 || (7...9).contains(digit) {
            return .forbiddenDigit
        }
        guard currentCode.count < 12 else { return .maxLengthReached }
        currentCode.append("\(digit)")
        return .appended
    }

    func deleteLastDigit() {
        guard !currentCode.isEmpty else { return }
        currentCode.removeLast()
    }

    func clearCode() {
        currentCode = ""
    }

    func setCompatibility(_ enabled: Bool) {
        useCompatibility = enabled
    }

    // MARK: - 提交

    func submitCode() {
        guard !currentCode.isEmpty else {
            delegate?.paygoViewModel(self, didSubmitFailure: "Input error")
            return
        }

        NetworkService.shared.submitPaygoPassword(
            code: currentCode,
            useCompatibility: useCompatibility
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                switch response.resultType {
                case .success:
                    self.delegate?.paygoViewModelDidSubmitSuccess(self)
                case .wrongCode:
                    self.delegate?.paygoViewModel(self, didSubmitFailure: "Wrong code")
                case .blocked(let seconds):
                    self.delegate?.paygoViewModel(self, didGetBlocked: seconds)
                }
            case .failure(let error):
                self.delegate?.paygoViewModel(self, didSubmitFailure: error.localizedDescription)
            }
        }
    }

    // MARK: - 信息轮询

    func startInfoPolling() {
        fetchInfo()
        infoTimer?.invalidate()
        infoTimer = Timer.scheduledTimer(withTimeInterval: AppConfig.dataRefreshInterval, repeats: true) { [weak self] _ in
            self?.fetchInfo()
        }
    }

    func stopInfoPolling() {
        infoTimer?.invalidate()
        infoTimer = nil
    }

    func refreshInfo() {
        fetchInfo()
    }

    private func fetchInfo() {
        NetworkService.shared.fetchPaygoInfo { [weak self] result in
            guard let self = self else { return }
            if case .success(let response) = result {
                self.deviceInfo = response.info
                self.delegate?.paygoViewModel(self, didUpdateInfo: response.info)
            }
        }
    }
}
