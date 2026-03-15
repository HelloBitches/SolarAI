import UIKit

extension UIView {

    /// Pin all edges to superview with optional insets
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

    /// Pin all edges to superview's safe area with optional insets
    func pinToSafeArea(of viewController: UIViewController, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        let guide = viewController.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: guide.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -insets.bottom)
        ])
    }

    /// Center in superview
    func centerInSuperview() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }

    /// Set fixed size constraints
    func setSize(width: CGFloat? = nil, height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        if let w = width {
            widthAnchor.constraint(equalToConstant: w).isActive = true
        }
        if let h = height {
            heightAnchor.constraint(equalToConstant: h).isActive = true
        }
    }

    /// Add rounded corner with optional border
    func addRoundedCorners(radius: CGFloat, borderColor: UIColor? = nil, borderWidth: CGFloat = 0) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
        if let color = borderColor {
            layer.borderColor = color.cgColor
            layer.borderWidth = borderWidth
        }
    }

    /// Add gradient background
    @discardableResult
    func addGradientLayer(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
        return gradient
    }
}
