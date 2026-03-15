import UIKit

/// Displays the animated energy flow diagram (isometric house illustration)
/// Cycles through 6 animation frames based on the current flow type
final class EnergyFlowView: UIView {

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private var currentFlowType: EnergyFlowType = .noConnect
    private var animationTimer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        showNoConnect()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        showNoConnect()
    }

    deinit {
        stopAnimation()
    }

    private func setupUI() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.pinToSuperview()
    }

    // MARK: - Public

    func updateFlowType(_ type: EnergyFlowType) {
        guard type != currentFlowType else { return }
        currentFlowType = type

        stopAnimation()

        if type == .noConnect {
            showNoConnect()
        } else {
            startAnimation(for: type)
        }
    }

    // MARK: - Animation

    private func showNoConnect() {
        imageView.stopAnimating()
        imageView.image = UIImage(named: "no_connect")
    }

    private func startAnimation(for type: EnergyFlowType) {
        var frames: [UIImage] = []
        for i in 0..<type.frameCount {
            let name = type.frameImageName(at: i)
            if let image = UIImage(named: name) {
                frames.append(image)
            }
        }

        guard !frames.isEmpty else {
            showNoConnect()
            return
        }

        imageView.animationImages = frames
        imageView.animationDuration = Double(frames.count) * AnimationConfig.flowFrameDuration
        imageView.animationRepeatCount = AnimationConfig.flowAnimationRepeat
        imageView.startAnimating()
    }

    private func stopAnimation() {
        imageView.stopAnimating()
        imageView.animationImages = nil
    }
}
