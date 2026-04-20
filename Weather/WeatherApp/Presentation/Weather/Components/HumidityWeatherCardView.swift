import UIKit

final class HumidityWeatherCardView: WeatherCardContainerView {
    private let valueLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(with current: MockWeatherData.Current) {
        valueLabel.text = "\(current.humidity) %"
        let dewPoint = Double(current.low).formatted(unit: AppSettings.shared.temperatureUnit)
        subtitleLabel.text = "Точка росы сейчас: \(dewPoint)."
    }

    private func setupView() {
        valueLabel.font = .systemFont(ofSize: 28, weight: .medium)
        valueLabel.textColor = .white

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        subtitleLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [
            makeHeaderRow(iconName: "humidity", title: "ВЛАЖНОСТЬ"),
            valueLabel,
            makeSpacer(),
            subtitleLabel
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8
        embedContent(stack)
    }
}
