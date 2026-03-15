import UIKit

/// Faulty Alert tab — displays parsed error codes, events, and solutions
final class FaultyAlertViewController: UIViewController {

    // MARK: - Properties

    private let viewModel = FaultyAlertViewModel()

    // MARK: - UI Elements

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let noAlertLabel: UILabel = {
        let label = UILabel()
        label.text = "No active faults or warnings"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = AppColors.textSecondary
        label.textAlignment = .center
        return label
    }()

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
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.pinToSuperview()

        contentStack.axis = .vertical
        contentStack.spacing = 0
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

        view.addSubview(noAlertLabel)
        noAlertLabel.translatesAutoresizingMaskIntoConstraints = false
        noAlertLabel.centerInSuperview()
    }

    private func updateFaultDisplay() {
        // Clear existing views
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let items = viewModel.faultItems
        noAlertLabel.isHidden = !items.isEmpty
        scrollView.isHidden = items.isEmpty

        for item in items {
            let faultView = FaultItemView(item: item)
            contentStack.addArrangedSubview(faultView)

            let separator = UIView()
            separator.backgroundColor = AppColors.separator
            separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
            contentStack.addArrangedSubview(separator)
        }
    }
}

// MARK: - FaultyAlertViewModelDelegate

extension FaultyAlertViewController: FaultyAlertViewModelDelegate {

    func faultyAlertViewModelDidUpdate(_ viewModel: FaultyAlertViewModel) {
        updateFaultDisplay()
    }

    func faultyAlertViewModel(_ viewModel: FaultyAlertViewModel, didFailWithError error: String) {
        // Silently retry on next poll
    }
}

// MARK: - Fault Item View

/// A single fault item row with code, event, and solution
private final class FaultItemView: UIView {

    init(item: FaultItem) {
        super.init(frame: .zero)
        setupUI(with: item)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupUI(with item: FaultItem) {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill

        let codeRow = createRow(label: "Faulty code:", value: item.code, valueColor: AppColors.error)
        let eventRow = createRow(label: "Faulty Event:", value: item.event, valueColor: AppColors.error)
        let solutionRow = createRow(label: "Faulty solution:", value: item.solution, valueColor: AppColors.error)

        stack.addArrangedSubview(codeRow)
        stack.addArrangedSubview(eventRow)
        stack.addArrangedSubview(solutionRow)

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }

    private func createRow(label: String, value: String, valueColor: UIColor) -> UIView {
        let container = UIView()

        let labelView = UILabel()
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        labelView.textColor = AppColors.textPrimary
        labelView.setContentHuggingPriority(.required, for: .horizontal)

        let valueView = UILabel()
        valueView.text = value
        valueView.font = UIFont.systemFont(ofSize: 14)
        valueView.textColor = valueColor
        valueView.numberOfLines = 0

        container.addSubview(labelView)
        container.addSubview(valueView)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        valueView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: container.topAnchor),
            labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            labelView.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor),

            valueView.topAnchor.constraint(equalTo: container.topAnchor),
            valueView.leadingAnchor.constraint(equalTo: labelView.trailingAnchor, constant: 8),
            valueView.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
            valueView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }
}
