import UIKit
import SnapKit

class WeatherCardContainerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCardAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCardAppearance()
    }

    func makeHeaderRow(iconName: String, title: String) -> UIView {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.image = UIImage(systemName: iconName, withConfiguration: config)
        iconView.tintColor = UIColor.white.withAlphaComponent(0.6)
        iconView.snp.makeConstraints { make in
            make.size.equalTo(14)
        }

        let label = UILabel()
        label.attributedText = NSAttributedString(
            string: title,
            attributes: [.kern: 1.0]
        )
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.6)

        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        stack.snp.makeConstraints { make in
            make.height.equalTo(16)
        }

        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stack
    }

    func makeSpacer() -> UIView {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        return spacer
    }

    func makeSeparator(alpha: CGFloat) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        view.snp.makeConstraints { make in
            make.height.equalTo(0.5)
        }
        return view
    }

    func embedContent(_ content: UIView) {
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    private func setupCardAppearance() {
        backgroundColor = UIColor.white.withAlphaComponent(0.15)
        layer.cornerRadius = 16
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(150)
        }
    }
}
