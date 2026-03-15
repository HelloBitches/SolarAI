import UIKit
import SnapKit

/// 显示动态能源流向图（等角房屋示意图）
/// 根据当前流向类型循环播放动画帧
final class EnergyFlowView: UIView {

    /// 图片视图，填满整个视图，scaleAspectFit
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private var currentFlowType: EnergyFlowType = .noConnect

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

    private func setupUI() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - 公开方法

    /// 更新能源流向类型
    /// - Parameter type: 能源流向类型（含 frameCount、frameImageName(at:)）
    func updateFlowType(_ type: EnergyFlowType) {
        guard type != currentFlowType else { return }
        currentFlowType = type

        if type == .noConnect {
            // 无连接：显示静态图片
            showNoConnect()
        } else {
            // 其他类型：建立 6 帧动画，总时长 = 每帧时长 × 帧数
            startAnimation(for: type)
        }
    }

    // MARK: - 动画

    /// 显示无连接静态图
    private func showNoConnect() {
        imageView.image = UIImage(named: "no_connect")
    }

    /// 启动动画
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

        // 使用 UIImage.animatedImage，总时长 = AnimationConfig.flowFrameDuration × 帧数
        let duration = AnimationConfig.flowFrameDuration * Double(type.frameCount)
        imageView.image = UIImage.animatedImage(with: frames, duration: duration)
    }
}
