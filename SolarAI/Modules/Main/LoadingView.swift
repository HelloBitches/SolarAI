import UIKit
import SnapKit

/// 全萤幕半透明载入遮罩，包含旋转指示器与消息文字
final class LoadingView: UIView {

    // MARK: - 子视图

    /// 白色圆角容器
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.2
        v.layer.shadowRadius = 10
        return v
    }()

    /// 绿色旋转指示器（大尺寸）
    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .large)
        s.color = AppColors.confirm
        s.hidesWhenStopped = true
        return s
    }()

    /// 消息标签，显示于旋转指示器下方
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        return label
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - 布局

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.4)

        addSubview(containerView)
        containerView.addSubview(spinner)
        containerView.addSubview(messageLabel)

        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 200, height: 140))
        }

        spinner.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(spinner.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
    }

    // MARK: - 公开方法

    /// 显示载入视图并设定消息
    func show(message: String) {
        messageLabel.text = message
        spinner.startAnimating()
        isHidden = false
        alpha = 0
        UIView.animate(withDuration: 0.25) { self.alpha = 1 }
    }

    /// 更新消息文字
    func updateMessage(_ message: String) {
        messageLabel.text = message
    }

    /// 隐藏载入视图（带淡出动画）
    func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { _ in
            self.isHidden = true
            self.spinner.stopAnimating()
        }
    }
}
