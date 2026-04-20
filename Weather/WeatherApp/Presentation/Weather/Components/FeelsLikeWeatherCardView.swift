import UIKit

final class FeelsLikeWeatherCardView: WeatherCardContainerView {
    private let tempLabel = UILabel()
    private let descriptionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(with current: MockWeatherData.Current) {
        tempLabel.text = Double(current.feelsLike).formatted(unit: AppSettings.shared.temperatureUnit)
    }

    private func setupView() {
        tempLabel.font = .systemFont(ofSize: 28, weight: .medium)
        tempLabel.textColor = .white

        descriptionLabel.text = "По ощущениям теплее, чем на самом деле."
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        descriptionLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [
            makeHeaderRow(iconName: "thermometer.medium", title: "ОЩУЩАЕТСЯ КАК"),
            tempLabel,
            makeSpacer(),
            descriptionLabel
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8
        embedContent(stack)
    }
}
