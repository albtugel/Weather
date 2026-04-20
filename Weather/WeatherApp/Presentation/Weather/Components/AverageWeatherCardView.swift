import UIKit

final class AverageWeatherCardView: WeatherCardContainerView {
    private let valueLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let leftMiniLabel = UILabel()
    private let rightMiniLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(with current: MockWeatherData.Current) {
        let unit = AppSettings.shared.temperatureUnit
        valueLabel.text = "На \(Double(current.averageTemp).formatted(unit: unit))"
        subtitleLabel.text = WeatherDetailFormatting.formattedAverageDelta(current.averageTempDelta)
        leftMiniLabel.text = "Сегодня  Макс.:\(Double(current.high).formatted(unit: unit))"
        rightMiniLabel.text = "В среднем  Макс.:\(Double(current.averageTemp).formatted(unit: unit))"
    }

    private func setupView() {
        valueLabel.font = .systemFont(ofSize: 28, weight: .medium)
        valueLabel.textColor = .white

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        subtitleLabel.numberOfLines = 0

        leftMiniLabel.font = .systemFont(ofSize: 12, weight: .regular)
        leftMiniLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        leftMiniLabel.adjustsFontSizeToFitWidth = true

        rightMiniLabel.font = .systemFont(ofSize: 12, weight: .regular)
        rightMiniLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        rightMiniLabel.textAlignment = .right
        rightMiniLabel.adjustsFontSizeToFitWidth = true

        let miniRow = UIStackView(arrangedSubviews: [leftMiniLabel, rightMiniLabel])
        miniRow.axis = .horizontal
        miniRow.alignment = .center
        miniRow.distribution = .fillEqually
        miniRow.spacing = 4

        let stack = UIStackView(arrangedSubviews: [
            makeHeaderRow(iconName: "chart.line.uptrend.xyaxis", title: "В СРЕДНЕМ"),
            valueLabel,
            subtitleLabel,
            makeSpacer(),
            miniRow
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8
        embedContent(stack)
    }
}
