import SnapKit
import UIKit

final class Dots: UIView {
    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func render(count: Int, index: Int, hasLocation: Bool) {
        stack.arrangedSubviews.forEach {
            stack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        guard count > 0 else { return }

        for item in 0..<count {
            let view = item == 0 && hasLocation ? locationDot(active: item == index) : dot(active: item == index)
            stack.addArrangedSubview(view)
        }
    }

    private func setup() {
        isUserInteractionEnabled = false

        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 7

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(18)
        }
    }

    private func dot(active: Bool) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(active ? 0.95 : 0.35)
        view.layer.cornerRadius = active ? 3.5 : 3
        view.snp.makeConstraints { make in
            make.size.equalTo(active ? 7 : 6)
        }
        return view
    }

    private func locationDot(active: Bool) -> UIImageView {
        let config = UIImage.SymbolConfiguration(pointSize: active ? 9 : 8, weight: .semibold)
        let view = UIImageView(image: UIImage(systemName: "location.fill", withConfiguration: config))
        view.tintColor = UIColor.white.withAlphaComponent(active ? 0.95 : 0.4)
        view.contentMode = .scaleAspectFit
        view.snp.makeConstraints { make in
            make.size.equalTo(14)
        }
        return view
    }
}
