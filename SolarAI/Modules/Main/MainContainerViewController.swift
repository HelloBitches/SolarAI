import UIKit

/// Main container with side tab bar (right) and content area (left)
/// Hosts General, StatusView, FaultyAlert, and PAYGO child view controllers
final class MainContainerViewController: UIViewController {

    // MARK: - Properties

    private let deviceName: String
    private var sideTabBar: SideTabBarView!
    private let contentContainer = UIView()
    private var childControllers: [UIViewController] = []
    private var currentChildIndex: Int = -1

    // MARK: - Init

    init(deviceName: String) {
        self.deviceName = deviceName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupChildControllers()
        setupUI()
        showChild(at: 0)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .landscapeLeft }

    // MARK: - Setup

    private func setupChildControllers() {
        let generalVC = GeneralViewController(deviceName: deviceName)
        let statusVC = StatusViewController()
        let faultyVC = FaultyAlertViewController()
        let paygoVC = PaygoViewController()
        childControllers = [generalVC, statusVC, faultyVC, paygoVC]
    }

    private func setupUI() {
        view.backgroundColor = AppColors.background

        sideTabBar = SideTabBarView(deviceName: deviceName)
        sideTabBar.delegate = self

        view.addSubview(contentContainer)
        view.addSubview(sideTabBar)

        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        sideTabBar.translatesAutoresizingMaskIntoConstraints = false

        let tabWidth: CGFloat = 100
        NSLayoutConstraint.activate([
            // Side tab bar — right side
            sideTabBar.topAnchor.constraint(equalTo: view.topAnchor),
            sideTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sideTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sideTabBar.widthAnchor.constraint(equalToConstant: tabWidth),

            // Content area — fills the rest
            contentContainer.topAnchor.constraint(equalTo: view.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: sideTabBar.leadingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Child Management

    private func showChild(at index: Int) {
        guard index >= 0, index < childControllers.count, index != currentChildIndex else { return }

        // Remove current child
        if currentChildIndex >= 0 && currentChildIndex < childControllers.count {
            let current = childControllers[currentChildIndex]
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }

        // Add new child
        let child = childControllers[index]
        addChild(child)
        contentContainer.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.pinToSuperview()
        child.didMove(toParent: self)

        currentChildIndex = index
    }

    // MARK: - Exit Dialog

    private func showExitDialog() {
        let exitView = ExitConfirmView()
        exitView.delegate = self
        exitView.show(in: view)
    }
}

// MARK: - SideTabBarViewDelegate

extension MainContainerViewController: SideTabBarViewDelegate {

    func sideTabBarView(_ view: SideTabBarView, didSelectTabAt index: Int) {
        showChild(at: index)
    }

    func sideTabBarViewDidTapConnected(_ view: SideTabBarView) {
        showExitDialog()
    }
}

// MARK: - ExitConfirmViewDelegate

extension MainContainerViewController: ExitConfirmViewDelegate {

    func exitConfirmViewDidCancel(_ view: ExitConfirmView) {
        view.dismiss()
    }

    func exitConfirmViewDidConfirm(_ view: ExitConfirmView) {
        view.dismiss()
        WiFiManager.shared.disconnect(ssid: deviceName)
        navigationController?.popToRootViewController(animated: true)
    }
}
