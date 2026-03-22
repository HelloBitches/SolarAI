import UIKit

/// UIView 布局快捷方法扩展
/// 注意：大部分布局已使用 SnapKit，此扩展保留部分通用方法供兼容使用
extension UIView {

    /// 四边对齐父视图
    func pinToSuperview(insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ])
    }

    /// 居中于父视图
    func centerInSuperview() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }

    /// 设置固定尺寸
    func setSize(width: CGFloat? = nil, height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        if let w = width { widthAnchor.constraint(equalToConstant: w).isActive = true }
        if let h = height { heightAnchor.constraint(equalToConstant: h).isActive = true }
    }

    /// 添加圆角和可选边框
    func addRoundedCorners(radius: CGFloat, borderColor: UIColor? = nil, borderWidth: CGFloat = 0) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
        if let color = borderColor {
            layer.borderColor = color.cgColor
            layer.borderWidth = borderWidth
        }
    }
}
