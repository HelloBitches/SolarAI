import UIKit
import SnapKit

/// 主容器视图控制器：顶部水平标签栏 + 下方内容区
/// 管理子视图控制器：General、StatusView、FaultyAlert、Paygo
final class MainContainerViewController: UIViewController {

    // MARK: - 属性

    private let deviceName: String
    private var topTabBar: TopTabBarView!
    private let contentContainer = UIView()
    private var childControllers: [UIViewController] = []
    private var currentChildIndex: Int = -1

    // MARK: - 初始化

    init(deviceName: String) {
        self.deviceName = deviceName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupChildControllers()
        setupUI()
        showChild(at: 0)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .landscapeLeft }

    // MARK: - 设定

    /// 建立四个子视图控制器
    private func setupChildControllers() {
        let generalVC = GeneralViewController(deviceName: deviceName)
        let statusVC = StatusViewController()
        let faultyVC = FaultyAlertViewController()
        let paygoVC = PaygoViewController()
        childControllers = [generalVC, statusVC, faultyVC, paygoVC]
    }

    /// 设定顶部标签栏与内容区布局
    private func setupUI() {
        view.backgroundColor = AppColors.background

        topTabBar = TopTabBarView(deviceName: deviceName)
        topTabBar.delegate = self

        view.addSubview(topTabBar)
        view.addSubview(contentContainer)

        // 顶部标签栏：高度 50，贴齐顶部
        topTabBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }

        // 内容区：紧贴标签栏下方，填满剩余空间
        contentContainer.snp.makeConstraints { make in
            make.top.equalTo(topTabBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - 子视图控制器管理

    /// 切换显示指定索引的子视图控制器
    private func showChild(at index: Int) {
        guard index >= 0, index < childControllers.count, index != currentChildIndex else { return }

        // 移除当前子控制器
        if currentChildIndex >= 0 && currentChildIndex < childControllers.count {
            let current = childControllers[currentChildIndex]
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }

        // 加入并显示新子控制器
        let child = childControllers[index]
        addChild(child)
        contentContainer.addSubview(child.view)
        child.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        child.didMove(toParent: self)

        currentChildIndex = index
    }

    // MARK: - 退出确认对话框

    private func showExitDialog() {
        let exitView = ExitConfirmView()
        exitView.delegate = self
        exitView.show(in: view)
    }
}

// MARK: - TopTabBarViewDelegate

extension MainContainerViewController: TopTabBarViewDelegate {

    func topTabBarView(_ view: TopTabBarView, didSelectTabAt index: Int) {
        showChild(at: index)
    }

    func topTabBarViewDidTapConnected(_ view: TopTabBarView) {
        showExitDialog()
    }
}

// MARK: - ExitConfirmViewDelegate

extension MainContainerViewController: ExitConfirmViewDelegate {

    func didCancel(_ view: ExitConfirmView) {
        view.dismiss()
    }

    func didConfirm(_ view: ExitConfirmView) {
        view.dismiss()
        navigationController?.popToRootViewController(animated: true)
    }
}
