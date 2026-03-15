import UIKit

/// PAYGO tab — number pad for entering unlock codes, with branding and compatibility toggle
final class PaygoViewController: UIViewController {

    // MARK: - Properties

    private let viewModel = PaygoViewModel()

    // MARK: - UI Elements

    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "input_code_bg")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.alpha = 0.3
        return iv
    }()

    private let keypadContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#4A5B6B").withAlphaComponent(0.95)
        v.layer.cornerRadius = 12
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.3
        v.layer.shadowRadius = 8
        return v
    }()

    private let displayLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(hex: "#6B7B8B").withAlphaComponent(0.5)
        label.textColor = AppColors.textPrimary
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 6
        label.clipsToBounds = true
        label.text = ""
        return label
    }()

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Input code"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = AppColors.textSecondary
        label.textAlignment = .center
        return label
    }()

    private let compatibilityStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        return sv
    }()

    private let compatibilityCheckbox: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "square"), for: .normal)
        btn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        btn.tintColor = AppColors.accent
        return btn
    }()

    private let compatibilityLabel: UILabel = {
        let label = UILabel()
        label.text = "Compatibility"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = AppColors.textPrimary
        return label
    }()

    private let paygoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "PAYGO ENERGY"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = AppColors.accent
        label.textAlignment = .center
        return label
    }()

    private var keypadButtons: [UIButton] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupUI()
        setupKeypad()
        viewModel.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startInfoPolling()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopInfoPolling()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.pinToSuperview()

        view.addSubview(paygoTitleLabel)
        view.addSubview(keypadContainer)
        view.addSubview(infoLabel)
        view.addSubview(resultLabel)
        view.addSubview(compatibilityStack)

        compatibilityStack.addArrangedSubview(compatibilityCheckbox)
        compatibilityStack.addArrangedSubview(compatibilityLabel)

        keypadContainer.addSubview(displayLabel)

        [paygoTitleLabel, keypadContainer, infoLabel, resultLabel, compatibilityStack, displayLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            // PAYGO title — top
            paygoTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            paygoTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Keypad container — centered
            keypadContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            keypadContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 8),
            keypadContainer.widthAnchor.constraint(equalToConstant: 260),
            keypadContainer.heightAnchor.constraint(equalToConstant: 300),

            // Display area inside keypad
            displayLabel.topAnchor.constraint(equalTo: keypadContainer.topAnchor, constant: 12),
            displayLabel.leadingAnchor.constraint(equalTo: keypadContainer.leadingAnchor, constant: 12),
            displayLabel.trailingAnchor.constraint(equalTo: keypadContainer.trailingAnchor, constant: -12),
            displayLabel.heightAnchor.constraint(equalToConstant: 40),

            // Result label — below keypad
            resultLabel.topAnchor.constraint(equalTo: keypadContainer.bottomAnchor, constant: 8),
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Info label — below result
            infoLabel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 4),
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Compatibility — bottom
            compatibilityStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            compatibilityStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])

        compatibilityCheckbox.addTarget(self, action: #selector(toggleCompatibility), for: .touchUpInside)
    }

    private func setupKeypad() {
        // 4 rows x 3 columns: 1-9, X(clear), 0, ✓(submit)
        let keys: [[String]] = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            ["✕", "0", "✓"]
        ]

        let gridStack = UIStackView()
        gridStack.axis = .vertical
        gridStack.spacing = 6
        gridStack.distribution = .fillEqually

        for row in keys {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 6
            rowStack.distribution = .fillEqually

            for key in row {
                let button = createKeyButton(title: key)
                rowStack.addArrangedSubview(button)
                keypadButtons.append(button)
            }

            gridStack.addArrangedSubview(rowStack)
        }

        keypadContainer.addSubview(gridStack)
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gridStack.topAnchor.constraint(equalTo: displayLabel.bottomAnchor, constant: 10),
            gridStack.leadingAnchor.constraint(equalTo: keypadContainer.leadingAnchor, constant: 12),
            gridStack.trailingAnchor.constraint(equalTo: keypadContainer.trailingAnchor, constant: -12),
            gridStack.bottomAnchor.constraint(equalTo: keypadContainer.bottomAnchor, constant: -12),
        ])
    }

    private func createKeyButton(title: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        btn.backgroundColor = UIColor(white: 0.88, alpha: 1.0)
        btn.setTitleColor(UIColor(hex: "#4A5B6B"), for: .normal)
        btn.layer.cornerRadius = 8
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.15
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 2

        if title == "✕" || title == "✓" {
            btn.backgroundColor = UIColor(white: 0.82, alpha: 1.0)
            btn.layer.cornerRadius = btn.bounds.height / 2
        }

        btn.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
        return btn
    }

    // MARK: - Actions

    @objc private func keyTapped(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }

        hideResult()

        switch title {
        case "✕":
            viewModel.clearCode()
        case "✓":
            viewModel.submitCode()
        default:
            if let digit = Int(title) {
                viewModel.appendDigit(digit)
            }
        }

        displayLabel.text = viewModel.currentCode
    }

    @objc private func toggleCompatibility() {
        compatibilityCheckbox.isSelected.toggle()
        viewModel.setCompatibility(compatibilityCheckbox.isSelected)
    }

    // MARK: - Result Display

    private func showResult(text: String, color: UIColor) {
        resultLabel.text = text
        resultLabel.textColor = color
        resultLabel.isHidden = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.hideResult()
        }
    }

    private func hideResult() {
        resultLabel.isHidden = true
    }
}

// MARK: - PaygoViewModelDelegate

extension PaygoViewController: PaygoViewModelDelegate {

    func paygoViewModelDidSubmitSuccess(_ viewModel: PaygoViewModel) {
        showResult(text: "Code accepted!", color: AppColors.confirm)
        viewModel.clearCode()
        displayLabel.text = ""
    }

    func paygoViewModel(_ viewModel: PaygoViewModel, didSubmitFailure message: String) {
        showResult(text: message, color: AppColors.error)
    }

    func paygoViewModel(_ viewModel: PaygoViewModel, didUpdateInfo info: String) {
        infoLabel.text = info
    }

    func paygoViewModel(_ viewModel: PaygoViewModel, didGetBlocked remainingSeconds: Int) {
        showResult(text: "Blocked. Wait \(remainingSeconds)s", color: AppColors.error)
    }
}
