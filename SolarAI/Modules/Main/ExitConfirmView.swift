import UIKit

protocol ExitConfirmViewDelegate: AnyObject {
    func exitConfirmViewDidCancel(_ view: ExitConfirmView)
    func exitConfirmViewDidConfirm(_ view: ExitConfirmView)
}

/// Modal dialog asking "Whether to exit the current device"
final class ExitConfirmView: UIView {

    weak var delegate: ExitConfirmViewDelegate?

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = AppColors.cardBackground
        v.layer.cornerRadius = 12
        return v
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Whether to exit the current device"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = AppColors.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let separatorLine: UIView = {
        let v = UIView()
        v.backgroundColor = AppColors.separator
        return v
    }()

    private let verticalSeparator: UIView = {
        let v = UIView()
        v.backgroundColor = AppColors.separator
        return v
    }()

    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(AppColors.textPrimary, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return btn
    }()

    private let confirmButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Confirm", for: .normal)
        btn.setTitleColor(AppColors.confirm, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupActions()
    }

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)

        addSubview(containerView)
        [messageLabel, separatorLine, cancelButton, confirmButton, verticalSeparator].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),

            messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 28),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            separatorLine.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            separatorLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),

            cancelButton.topAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: containerView.centerXAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 48),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            confirmButton.topAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            confirmButton.leadingAnchor.constraint(equalTo: containerView.centerXAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 48),

            verticalSeparator.topAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            verticalSeparator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            verticalSeparator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            verticalSeparator.widthAnchor.constraint(equalToConstant: 0.5),
        ])
    }

    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
    }

    @objc private func cancelTapped() {
        delegate?.exitConfirmViewDidCancel(self)
    }

    @objc private func confirmTapped() {
        delegate?.exitConfirmViewDidConfirm(self)
    }

    func show(in parentView: UIView) {
        parentView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        pinToSuperview()
        alpha = 0
        UIView.animate(withDuration: 0.25) { self.alpha = 1 }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
