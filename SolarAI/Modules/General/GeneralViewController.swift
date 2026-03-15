import UIKit

/// General tab — displays connection state, hardware module grid, and device version
final class GeneralViewController: UIViewController {

    // MARK: - Properties

    private let viewModel = GeneralViewModel()
    private let deviceName: String

    // MARK: - UI Elements

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // Connect State Section
    private let connectStateHeader = SectionHeaderView(title: "Connect state")
    private let heartbeatIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "hw_orange_0") // heartbeat orange
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let heartbeatLabel: UILabel = {
        let label = UILabel()
        label.text = "Heartbeat"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = AppColors.accent
        return label
    }()

    // Hardware State Section
    private let hardwareStateHeader = SectionHeaderView(title: "Hardware state")
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.register(HardwareStatusCell.self, forCellWithReuseIdentifier: HardwareStatusCell.reuseIdentifier)
        cv.isScrollEnabled = false
        return cv
    }()

    // BaseInfo Section
    private let baseInfoHeader = SectionHeaderView(title: "BaseInfo")
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "Device version: --"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = AppColors.textPrimary
        return label
    }()

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
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.pinToSuperview()

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])

        // Connect State
        let heartbeatRow = UIStackView(arrangedSubviews: [heartbeatIcon, heartbeatLabel])
        heartbeatRow.axis = .horizontal
        heartbeatRow.spacing = 8
        heartbeatRow.alignment = .center
        heartbeatIcon.setSize(width: 32, height: 32)

        contentStack.addArrangedSubview(connectStateHeader)
        contentStack.addArrangedSubview(heartbeatRow)

        // Hardware State
        contentStack.addArrangedSubview(hardwareStateHeader)
        contentStack.addArrangedSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.heightAnchor.constraint(equalToConstant: 280).isActive = true

        // BaseInfo
        contentStack.addArrangedSubview(baseInfoHeader)
        contentStack.addArrangedSubview(versionLabel)
    }
}

// MARK: - GeneralViewModelDelegate

extension GeneralViewController: GeneralViewModelDelegate {

    func generalViewModelDidUpdateData(_ viewModel: GeneralViewModel) {
        versionLabel.text = "Device version: \(viewModel.deviceVersion)"
        heartbeatIcon.image = UIImage(named: viewModel.isHeartbeatActive ? "hw_orange_0" : "hw_gray_0")
        heartbeatLabel.textColor = viewModel.isHeartbeatActive ? AppColors.accent : AppColors.textSecondary
        collectionView.reloadData()
    }

    func generalViewModel(_ viewModel: GeneralViewModel, didFailWithError error: String) {
        // Silently handle in the background; data will refresh on next poll
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension GeneralViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HardwareIcon.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HardwareStatusCell.reuseIdentifier,
            for: indexPath
        ) as! HardwareStatusCell
        let icon = HardwareIcon.allCases[indexPath.item]
        let isActive = viewModel.activeHardwareModules.contains(icon.statusBit)
        cell.configure(icon: icon, isActive: isActive)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let columns: CGFloat = 6
        let spacing: CGFloat = 8
        let totalSpacing = spacing * (columns - 1)
        let width = (collectionView.bounds.width - totalSpacing) / columns
        return CGSize(width: width, height: 65)
    }
}

// MARK: - Section Header View

final class SectionHeaderView: UIView {

    private let accentBar: UIView = {
        let v = UIView()
        v.backgroundColor = AppColors.accent
        v.layer.cornerRadius = 1.5
        return v
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = AppColors.textPrimary
        return label
    }()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(accentBar)
        addSubview(titleLabel)
        accentBar.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            accentBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            accentBar.centerYAnchor.constraint(equalTo: centerYAnchor),
            accentBar.widthAnchor.constraint(equalToConstant: 3),
            accentBar.heightAnchor.constraint(equalToConstant: 18),

            titleLabel.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),

            heightAnchor.constraint(equalToConstant: 30),
        ])
    }
}
