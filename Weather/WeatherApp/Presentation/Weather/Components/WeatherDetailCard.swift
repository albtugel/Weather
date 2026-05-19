import UIKit
import SnapKit

final class WeatherDetailCard: UIView {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let noteLabel = UILabel()
    private let rowStack = UIStackView()
    private let uvBar = UIView()
    private let uvMarker = UIView()
    private let uvGradient = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        uvGradient.frame = uvBar.bounds
        uvGradient.cornerRadius = uvBar.bounds.height / 2
    }

    func configure(with item: WeatherDetailItem) {
        iconView.image = UIImage(systemName: item.icon)
        titleLabel.attributedText = NSAttributedString(
            string: item.title.uppercased(),
            attributes: [.kern: 0.6]
        )
        valueLabel.text = item.value
        subtitleLabel.text = item.subtitle
        noteLabel.text = item.note

        rowStack.arrangedSubviews.forEach { view in
            rowStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        item.rows.forEach { rowStack.addArrangedSubview(makeRow($0)) }

        valueLabel.isHidden = item.kind == .wind
        rowStack.isHidden = item.kind != .wind
        uvBar.isHidden = item.kind != .uv
        uvMarker.isHidden = item.kind != .uv
        subtitleLabel.isHidden = item.subtitle == nil
        noteLabel.isHidden = item.note == nil
    }

    private func setupView() {
        backgroundColor = UIColor.white.withAlphaComponent(0.16)
        layer.cornerRadius = 16
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        clipsToBounds = true

        iconView.tintColor = UIColor.white.withAlphaComponent(0.56)
        iconView.contentMode = .scaleAspectFit

        titleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.58)
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.62
        titleLabel.lineBreakMode = .byClipping

        valueLabel.font = .systemFont(ofSize: 33, weight: .regular)
        valueLabel.textColor = .white
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.68

        subtitleLabel.font = .systemFont(ofSize: 13.5, weight: .semibold)
        subtitleLabel.textColor = .white
        subtitleLabel.numberOfLines = 3
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.82

        noteLabel.font = .systemFont(ofSize: 12.5, weight: .regular)
        noteLabel.textColor = UIColor.white.withAlphaComponent(0.86)
        noteLabel.numberOfLines = 3
        noteLabel.adjustsFontSizeToFitWidth = true
        noteLabel.minimumScaleFactor = 0.82

        rowStack.axis = .vertical
        rowStack.spacing = 0
        rowStack.distribution = .fillEqually

        uvBar.layer.insertSublayer(uvGradient, at: 0)
        uvBar.clipsToBounds = true
        uvGradient.colors = [
            UIColor.systemGreen.cgColor,
            UIColor.systemYellow.cgColor,
            UIColor.systemOrange.cgColor,
            UIColor.systemPink.cgColor
        ]
        uvGradient.startPoint = CGPoint(x: 0, y: 0.5)
        uvGradient.endPoint = CGPoint(x: 1, y: 0.5)

        uvMarker.backgroundColor = .white
        uvMarker.layer.cornerRadius = 2
    }

    private func setupLayout() {
        [iconView, titleLabel, valueLabel, subtitleLabel, noteLabel, rowStack, uvBar, uvMarker].forEach {
            addSubview($0)
        }

        iconView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(12)
            make.size.equalTo(14)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconView)
            make.leading.equalTo(iconView.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-12)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        uvBar.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(3)
        }

        uvMarker.snp.makeConstraints { make in
            make.centerY.equalTo(uvBar)
            make.leading.equalTo(uvBar.snp.leading).offset(10)
            make.width.equalTo(4)
            make.height.equalTo(7)
        }

        noteLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(uvBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().offset(-12)
        }

        rowStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func makeRow(_ row: WeatherDetailRow) -> UIView {
        let view = UIView()
        let nameLabel = UILabel()
        let valueLabel = UILabel()
        let line = UIView()

        nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = .white
        nameLabel.text = row.title
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.78
        nameLabel.lineBreakMode = .byClipping

        valueLabel.font = .systemFont(ofSize: 14, weight: .regular)
        valueLabel.textColor = UIColor.white.withAlphaComponent(0.72)
        valueLabel.textAlignment = .right
        valueLabel.text = row.value
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.78

        line.backgroundColor = UIColor.white.withAlphaComponent(0.13)

        [nameLabel, valueLabel, line].forEach { view.addSubview($0) }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.lessThanOrEqualTo(valueLabel.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(nameLabel.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }

        line.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }

        return view
    }
}
