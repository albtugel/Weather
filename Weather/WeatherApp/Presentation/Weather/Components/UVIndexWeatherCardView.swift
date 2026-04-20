import UIKit
import SnapKit

final class UVIndexWeatherCardView: WeatherCardContainerView {
    private let valueLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let footerLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(with current: MockWeatherData.Current) {
        valueLabel.text = "\(current.uvIndex)"
        subtitleLabel.text = current.uvDescription
        footerLabel.text = current.uvForecast
    }

    private func setupView() {
        valueLabel.font = .systemFont(ofSize: 28, weight: .medium)
        valueLabel.textColor = .white

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)

        footerLabel.font = .systemFont(ofSize: 13, weight: .regular)
        footerLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        footerLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [
            makeHeaderRow(iconName: "sun.max", title: "УФ-ИНДЕКС"),
            valueLabel,
            subtitleLabel,
            UVBarView(),
            footerLabel
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8
        embedContent(stack)
    }
}

private final class UVBarView: UIView {
    private let trackView = UIView()
    private let indicatorView = UIView()
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = trackView.bounds
    }

    private func setup() {
        snp.makeConstraints { make in
            make.height.equalTo(20)
        }

        trackView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        trackView.layer.cornerRadius = 2
        trackView.clipsToBounds = true

        gradientLayer.colors = [
            UIColor.systemGreen.cgColor,
            UIColor.systemYellow.cgColor,
            UIColor.systemOrange.cgColor,
            UIColor.systemRed.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        trackView.layer.addSublayer(gradientLayer)

        indicatorView.backgroundColor = .white
        indicatorView.layer.cornerRadius = 3

        addSubview(trackView)
        trackView.addSubview(indicatorView)

        trackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(4)
        }

        indicatorView.snp.makeConstraints { make in
            make.leading.equalTo(trackView.snp.leading)
            make.centerY.equalTo(trackView.snp.centerY)
            make.size.equalTo(6)
        }
    }
}
