import UIKit

/// Full-screen translucent loading overlay with spinner and message
final class LoadingView: UIView {

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.2
        v.layer.shadowRadius = 10
        return v
    }()

    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .large)
        s.color = AppColors.confirm
        s.hidesWhenStopped = true
        return s
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.4)

        addSubview(containerView)
        containerView.addSubview(spinner)
        containerView.addSubview(messageLabel)

        [containerView, spinner, messageLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 200),
            containerView.heightAnchor.constraint(equalToConstant: 140),

            spinner.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),

            messageLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
        ])
    }

    func show(message: String) {
        messageLabel.text = message
        spinner.startAnimating()
        isHidden = false
        alpha = 0
        UIView.animate(withDuration: 0.25) { self.alpha = 1 }
    }

    func updateMessage(_ message: String) {
        messageLabel.text = message
    }

    func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { _ in
            self.isHidden = true
            self.spinner.stopAnimating()
        }
    }
}
