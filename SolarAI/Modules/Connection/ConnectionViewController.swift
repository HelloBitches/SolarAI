import UIKit

/// Login/connection screen — user enters WiFi SSID (SSE...) and connects to inverter
final class ConnectionViewController: UIViewController {

    // MARK: - Properties

    private let viewModel = ConnectionViewModel()
    private var gradientLayer: CAGradientLayer?

    // MARK: - UI Elements

    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "login_bg")
        iv.alpha = 0.7
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = AppConfig.appName
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = AppColors.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "version: \(AppConfig.appVersion)"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = AppColors.textSecondary
        return label
    }()

    private let formContainer: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.cardBackground.withAlphaComponent(0.95)
        view.layer.cornerRadius = 12
        return view
    }()

    private let wifiNameLabel: UILabel = {
        let label = UILabel()
        label.text = "WiFi NAME:"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = AppColors.textSecondary
        return label
    }()

    private let wifiNameField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = AppColors.inputBackground
        tf.textColor = AppColors.textPrimary
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.layer.cornerRadius = 8
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        tf.leftViewMode = .always
        tf.placeholder = "Enter SSE... WiFi name"
        tf.attributedPlaceholder = NSAttributedString(
            string: "Enter SSE... WiFi name",
            attributes: [.foregroundColor: UIColor(white: 0.4, alpha: 1)]
        )
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .allCharacters
        tf.returnKeyType = .done
        return tf
    }()

    private let wifiPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "WiFi PASSWORD:"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = AppColors.textSecondary
        return label
    }()

    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = AppColors.inputBackground
        tf.textColor = AppColors.textPrimary
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.layer.cornerRadius = 8
        tf.isSecureTextEntry = true
        tf.text = AppConfig.defaultPassword
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        tf.leftViewMode = .always
        return tf
    }()

    private let togglePasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        btn.tintColor = AppColors.textSecondary
        return btn
    }()

    private let connectButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Click to connect", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = AppColors.accent
        btn.layer.cornerRadius = 25
        return btn
    }()

    private let wifiIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "wifi")
        iv.tintColor = UIColor.systemBlue
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let hintLabel: UILabel = {
        let label = UILabel()
        label.text = "Look for WiFi starting with SSE"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = AppColors.textSecondary
        return label
    }()

    private let refreshButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(" Search WiFi", for: .normal)
        btn.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        btn.tintColor = AppColors.textPrimary
        btn.setTitleColor(AppColors.textPrimary, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return btn
    }()

    private let loadingView = LoadingView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        viewModel.delegate = self
        wifiNameField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = connectButton.bounds
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .landscapeLeft }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = AppColors.background

        [backgroundImageView, versionLabel, titleLabel, formContainer,
         wifiIcon, hintLabel, refreshButton, loadingView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [wifiNameLabel, wifiNameField, wifiPasswordLabel, passwordField,
         togglePasswordButton, connectButton].forEach {
            formContainer.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.55),

            versionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            versionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),

            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 220),

            formContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            formContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            formContainer.widthAnchor.constraint(equalToConstant: 320),

            wifiNameLabel.topAnchor.constraint(equalTo: formContainer.topAnchor, constant: 20),
            wifiNameLabel.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 20),

            wifiNameField.topAnchor.constraint(equalTo: wifiNameLabel.bottomAnchor, constant: 6),
            wifiNameField.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 20),
            wifiNameField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -20),
            wifiNameField.heightAnchor.constraint(equalToConstant: 40),

            wifiPasswordLabel.topAnchor.constraint(equalTo: wifiNameField.bottomAnchor, constant: 14),
            wifiPasswordLabel.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 20),

            passwordField.topAnchor.constraint(equalTo: wifiPasswordLabel.bottomAnchor, constant: 6),
            passwordField.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -50),
            passwordField.heightAnchor.constraint(equalToConstant: 40),

            togglePasswordButton.centerYAnchor.constraint(equalTo: passwordField.centerYAnchor),
            togglePasswordButton.leadingAnchor.constraint(equalTo: passwordField.trailingAnchor, constant: 4),
            togglePasswordButton.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -16),
            togglePasswordButton.widthAnchor.constraint(equalToConstant: 30),

            connectButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 24),
            connectButton.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor, constant: 40),
            connectButton.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor, constant: -40),
            connectButton.heightAnchor.constraint(equalToConstant: 50),
            connectButton.bottomAnchor.constraint(equalTo: formContainer.bottomAnchor, constant: -20),

            wifiIcon.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            wifiIcon.trailingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: -6),
            wifiIcon.widthAnchor.constraint(equalToConstant: 20),
            wifiIcon.heightAnchor.constraint(equalToConstant: 20),

            hintLabel.centerYAnchor.constraint(equalTo: wifiIcon.centerYAnchor),
            hintLabel.trailingAnchor.constraint(equalTo: wifiIcon.leadingAnchor, constant: -8),

            refreshButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            refreshButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            refreshButton.heightAnchor.constraint(equalToConstant: 30),

            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        loadingView.isHidden = true

        let gradient = CAGradientLayer()
        gradient.colors = [AppColors.accentGradientStart.cgColor, AppColors.accentGradientEnd.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 25
        connectButton.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }

    private func setupActions() {
        connectButton.addTarget(self, action: #selector(connectTapped), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        togglePasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Actions

    @objc private func connectTapped() {
        dismissKeyboard()
        let ssid = wifiNameField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password = passwordField.text ?? AppConfig.defaultPassword
        viewModel.connect(ssid: ssid, password: password, from: self)
    }

    @objc private func refreshTapped() {
        viewModel.openWiFiSettings()
    }

    @objc private func togglePasswordVisibility() {
        passwordField.isSecureTextEntry.toggle()
        let iconName = passwordField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        togglePasswordButton.setImage(UIImage(systemName: iconName), for: .normal)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Navigation

    private func navigateToMain(deviceName: String) {
        let mainVC = MainContainerViewController(deviceName: deviceName)
        navigationController?.pushViewController(mainVC, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - ConnectionViewModelDelegate

extension ConnectionViewController: ConnectionViewModelDelegate {

    func didStartConnecting() {
        loadingView.show(message: "Wifi connecting")
    }

    func didConnectSuccessfully(deviceName: String) {
        loadingView.updateMessage("Device connecting")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.loadingView.hide()
            self?.navigateToMain(deviceName: deviceName)
        }
    }

    func didFailToConnect(error: String) {
        loadingView.hide()
        showAlert(title: "Connection Failed", message: error)
    }
}

// MARK: - UITextFieldDelegate

extension ConnectionViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
