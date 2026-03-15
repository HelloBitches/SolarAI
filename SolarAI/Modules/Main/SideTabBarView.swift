import UIKit

protocol SideTabBarViewDelegate: AnyObject {
    func sideTabBarView(_ view: SideTabBarView, didSelectTabAt index: Int)
    func sideTabBarViewDidTapConnected(_ view: SideTabBarView)
}

/// Right-side vertical tab bar mirroring the Android app's navigation
final class SideTabBarView: UIView {

    weak var delegate: SideTabBarViewDelegate?

    private let tabs = ["General", "Status View", "Faulty Alert", "PAYGO"]
    private(set) var selectedIndex: Int = 0

    private var deviceName: String

    // MARK: - UI Elements

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()

    private lazy var connectedButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = AppColors.cardBackground
        btn.setTitleColor(AppColors.textPrimary, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        btn.titleLabel?.numberOfLines = 3
        btn.titleLabel?.textAlignment = .center
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        return btn
    }()

    private var tabButtons: [UIButton] = []

    // MARK: - Init

    init(deviceName: String) {
        self.deviceName = deviceName
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        self.deviceName = ""
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = AppColors.cardBackground

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
        ])

        // Connected header button
        updateConnectedButton()
        connectedButton.addTarget(self, action: #selector(connectedTapped), for: .touchUpInside)
        connectedButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        stackView.addArrangedSubview(connectedButton)

        // Tab buttons
        for (index, title) in tabs.enumerated() {
            let button = createTabButton(title: title, index: index)
            tabButtons.append(button)
            stackView.addArrangedSubview(button)
        }

        updateSelection(index: 0, animated: false)
    }

    private func createTabButton(title: String, index: Int) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(AppColors.textPrimary, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        btn.titleLabel?.numberOfLines = 2
        btn.titleLabel?.textAlignment = .center
        btn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 6, bottom: 12, right: 6)
        btn.tag = index
        btn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        btn.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        return btn
    }

    private func updateConnectedButton() {
        let title = "Connected\n\(deviceName)\n▼"
        connectedButton.setTitle(title, for: .normal)
    }

    // MARK: - Selection

    func selectTab(at index: Int) {
        updateSelection(index: index, animated: true)
    }

    private func updateSelection(index: Int, animated: Bool) {
        selectedIndex = index
        let update = {
            for (i, button) in self.tabButtons.enumerated() {
                button.backgroundColor = i == index ? AppColors.tabSelected : AppColors.tabNormal
            }
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: update)
        } else {
            update()
        }
    }

    // MARK: - Actions

    @objc private func tabTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index != selectedIndex else { return }
        updateSelection(index: index, animated: true)
        delegate?.sideTabBarView(self, didSelectTabAt: index)
    }

    @objc private func connectedTapped() {
        delegate?.sideTabBarViewDidTapConnected(self)
    }
}
