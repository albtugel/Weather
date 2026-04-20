import UIKit
import SnapKit

final class WeatherDetailGridView: UIView {
    private let stackView = UIStackView()
    private var currentWeather: MockWeatherData.Current?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(temperatureUnitChanged),
            name: .temperatureUnitChanged,
            object: nil
        )
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupLayout()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(temperatureUnitChanged),
            name: .temperatureUnitChanged,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupView() {
        backgroundColor = .clear
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = false
        stackView.layoutMargins = .zero
    }

    private func setupLayout() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func makeSpacer() -> UIView {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        return spacer
    }

    func configure(with current: MockWeatherData.Current) {
        currentWeather = current
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let row1 = makeTwoColumnRow(
            left: makeAverageCard(current: current),
            right: makeFeelsLikeCard(current: current)
        )
        let windCard = makeWindCard(current: current)
        let row3 = makeTwoColumnRow(
            left: makeUVCard(current: current),
            right: makeSunsetCard(current: current)
        )
        let row4 = makeTwoColumnRow(
            left: makeHumidityCard(current: current),
            right: makePressureCard(current: current)
        )

        stackView.addArrangedSubview(row1)
        stackView.addArrangedSubview(windCard)
        stackView.addArrangedSubview(row3)
        stackView.addArrangedSubview(row4)
    }

    private func makeTwoColumnRow(left: UIView, right: UIView) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [left, right])
        row.axis = .horizontal
        row.alignment = .fill
        row.distribution = .fillEqually
        row.spacing = 8
        return row
    }

    private func makeCardContainer() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        card.layer.cornerRadius = 16
        card.clipsToBounds = true
        card.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(150)
        }
        return card
    }

    private func embedContent(_ content: UIView, in card: UIView) {
        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    private func headerRow(iconName: String, title: String) -> UIView {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.image = UIImage(systemName: iconName, withConfiguration: config)
        iconView.tintColor = UIColor.white.withAlphaComponent(0.6)
        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(14)
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

    private func makeAverageCard(current: MockWeatherData.Current) -> UIView {
        let card = makeCardContainer()

        let header = headerRow(iconName: "chart.line.uptrend.xyaxis", title: "В СРЕДНЕМ")

        let valueLabel = UILabel()
        valueLabel.text = "На \(Double(current.averageTemp).formatted(unit: AppSettings.shared.temperatureUnit))"
        valueLabel.font = .systemFont(ofSize: 28, weight: .medium)
        valueLabel.textColor = .white

        let subtitleLabel = UILabel()
        subtitleLabel.text = formattedAverageDelta(current.averageTempDelta)
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        subtitleLabel.numberOfLines = 0

        let leftMini = UILabel()
        leftMini.text = "Сегодня  Макс.:\(Double(current.high).formatted(unit: AppSettings.shared.temperatureUnit))"
        leftMini.font = .systemFont(ofSize: 12, weight: .regular)
        leftMini.textColor = UIColor.white.withAlphaComponent(0.6)
        leftMini.numberOfLines = 1
        leftMini.adjustsFontSizeToFitWidth = true

        let rightMini = UILabel()
        rightMini.text = "В среднем  Макс.:\(Double(current.averageTemp).formatted(unit: AppSettings.shared.temperatureUnit))"
        rightMini.font = .systemFont(ofSize: 12, weight: .regular)
        rightMini.textColor = UIColor.white.withAlphaComponent(0.6)
        rightMini.textAlignment = .right
        rightMini.numberOfLines = 1
        rightMini.adjustsFontSizeToFitWidth = true

        let miniRow = UIStackView(arrangedSubviews: [leftMini, rightMini])
        miniRow.axis = .horizontal
        miniRow.alignment = .center
        miniRow.distribution = .fillEqually
        miniRow.spacing = 4

        let stack = UIStackView(arrangedSubviews: [
            header,
            valueLabel,
            subtitleLabel,
            makeSpacer(),
            miniRow
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8

        embedContent(stack, in: card)
        return card
    }

    private func makeFeelsLikeCard(current: MockWeatherData.Current) -> UIView {
        let card = makeCardContainer()

        let header = headerRow(iconName: "thermometer.medium", title: "ОЩУЩАЕТСЯ КАК")

        let tempLabel = UILabel()
        let tempValue = Double(current.feelsLike)
        tempLabel.text = tempValue.formatted(unit: AppSettings.shared.temperatureUnit)
        tempLabel.font = .systemFont(ofSize: 28, weight: .medium)
        tempLabel.textColor = .white

        let descriptionLabel = UILabel()
        descriptionLabel.text = "По ощущениям теплее, чем на самом деле."
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        descriptionLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [
            header,
            tempLabel,
            makeSpacer(),
            descriptionLabel
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8

        embedContent(stack, in: card)
        return card
    }

    private func makeWindCard(current: MockWeatherData.Current) -> UIView {
        let card = makeCardContainer()

        let header = headerRow(iconName: "wind", title: "ВЕТЕР")

        let row1 = makeWindRow(title: "Ветер", value: "\(current.windSpeed) км/ч")
        let row2 = makeWindRow(title: "Порывы ветра", value: "\(current.windGust) км/ч")
        let row3 = makeWindRow(title: "Направление", value: current.windDirection)

        let separator1 = makeSeparator(alpha: 0.2)
        let separator2 = makeSeparator(alpha: 0.2)

        let stack = UIStackView(arrangedSubviews: [
            header,
            row1,
            separator1,
            row2,
            separator2,
            row3
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8

        embedContent(stack, in: card)
        return card
    }

    private func makeWindRow(title: String, value: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = .white

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .regular)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .right
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        return row
    }

    private func makeUVCard(current: MockWeatherData.Current) -> UIView {
        let card = makeCardContainer()

        let header = headerRow(iconName: "sun.max", title: "УФ-ИНДЕКС")

        let valueLabel = UILabel()
        valueLabel.text = "\(current.uvIndex)"
        valueLabel.font = .systemFont(ofSize: 28, weight: .medium)
        valueLabel.textColor = .white

        let subtitleLabel = UILabel()
        subtitleLabel.text = current.uvDescription
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)

        let barView = UVBarView()

        let footerLabel = UILabel()
        footerLabel.text = current.uvForecast
        footerLabel.font = .systemFont(ofSize: 13, weight: .regular)
        footerLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        footerLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [
            header,
            valueLabel,
            subtitleLabel,
            barView,
            footerLabel
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8

        embedContent(stack, in: card)
        return card
    }

    private func makeSunsetCard(current: MockWeatherData.Current) -> UIView {
        let card = makeCardContainer()

        let header = headerRow(iconName: "sunset.fill", title: "ЗАКАТ")

        let valueLabel = UILabel()
        valueLabel.text = formatTime(current.sunset)
        valueLabel.font = .systemFont(ofSize: 28, weight: .medium)
        valueLabel.textColor = .white

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Восход в \(formatTime(current.sunrise))."
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)

        let arcView = SunArcView()
        arcView.snp.makeConstraints { make in
            make.height.equalTo(60)
        }

        let stack = UIStackView(arrangedSubviews: [
            header,
            valueLabel,
            subtitleLabel,
            makeSpacer(),
            arcView
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8

        embedContent(stack, in: card)
        return card
    }

    private func makeHumidityCard(current: MockWeatherData.Current) -> UIView {
        let card = makeCardContainer()

        let header = headerRow(iconName: "humidity", title: "ВЛАЖНОСТЬ")

        let valueLabel = UILabel()
        valueLabel.text = "\(current.humidity) %"
        valueLabel.font = .systemFont(ofSize: 28, weight: .medium)
        valueLabel.textColor = .white

        let subtitleLabel = UILabel()
        let dewPoint = Double(current.low).formatted(unit: AppSettings.shared.temperatureUnit)
        subtitleLabel.text = "Точка росы сейчас: \(dewPoint)."
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        subtitleLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [
            header,
            valueLabel,
            makeSpacer(),
            subtitleLabel
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8

        embedContent(stack, in: card)
        return card
    }

    private func makePressureCard(current: MockWeatherData.Current) -> UIView {
        let card = makeCardContainer()

        let header = headerRow(iconName: "gauge.with.needle", title: "ДАВЛЕНИЕ")

        let valueLabel = UILabel()
        valueLabel.text = formatPressure(current.pressure)
        valueLabel.font = .systemFont(ofSize: 28, weight: .medium)
        valueLabel.textColor = .white

        let subtitleLabel = UILabel()
        subtitleLabel.text = pressureTrendText(current.pressureTrend)
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)

        let stack = UIStackView(arrangedSubviews: [
            header,
            valueLabel,
            makeSpacer(),
            subtitleLabel
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8

        embedContent(stack, in: card)
        return card
    }

    private func makeSeparator(alpha: CGFloat) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        view.snp.makeConstraints { make in
            make.height.equalTo(0.5)
        }
        return view
    }

    @objc private func temperatureUnitChanged() {
        guard let currentWeather else { return }
        configure(with: currentWeather)
    }
}

// MARK: - Private Helpers

private extension WeatherDetailGridView {
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    func formatPressure(_ value: Int) -> String {
        let string = String(value)
        guard string.count > 3 else { return string }
        let index = string.index(string.endIndex, offsetBy: -3)
        let prefix = String(string[..<index])
        let suffix = String(string[index...])
        return "\(prefix) \(suffix)"
    }

    func pressureTrendText(_ trend: String) -> String {
        switch trend {
        case "falling": return "↓ гПА"
        case "rising":  return "↑ гПА"
        default:        return "→ гПА"
        }
    }

    func formattedAverageDelta(_ text: String) -> String {
        guard AppSettings.shared.temperatureUnit == .fahrenheit else { return text }
        let pattern = "[-+]?\\d+°?"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range, in: text) else {
            return text
        }
        let matched = String(text[range]).replacingOccurrences(of: "°", with: "")
        let sign: String
        if matched.hasPrefix("-") { sign = "-" }
        else if matched.hasPrefix("+") { sign = "+" }
        else { sign = "" }
        let valueString = matched.trimmingCharacters(in: CharacterSet(charactersIn: "+-"))
        guard let value = Double(valueString) else { return text }
        let converted = value * 9 / 5
        let formatted = "\(sign)\(Int(converted.rounded()))°"
        return text.replacingCharacters(in: range, with: formatted)
    }
}

// MARK: - UVBarView

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
        gradientLayer.endPoint   = CGPoint(x: 1, y: 0.5)
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

// MARK: - SunArcView

private final class SunArcView: UIView {
    private let arcLayer  = CAShapeLayer()
    private let sunLayer  = CAShapeLayer()

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
        layoutArc()
    }

    private func setup() {
        backgroundColor = .clear
        arcLayer.strokeColor = UIColor.white.withAlphaComponent(0.6).cgColor
        arcLayer.fillColor   = UIColor.clear.cgColor
        arcLayer.lineWidth   = 2
        sunLayer.fillColor   = UIColor.white.cgColor
        layer.addSublayer(arcLayer)
        layer.addSublayer(sunLayer)
    }

    private func layoutArc() {
        let radius = min(bounds.width / 2, bounds.height) - 4
        let center = CGPoint(x: bounds.midX, y: bounds.maxY - 2)

        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: .pi,
            endAngle: 0,
            clockwise: true
        )
        arcLayer.path = path.cgPath

        let sunAngle: CGFloat = .pi * 0.75
        let sunCenter = CGPoint(
            x: center.x + radius * cos(sunAngle),
            y: center.y + radius * sin(sunAngle)
        )
        let r: CGFloat = 4
        sunLayer.path = UIBezierPath(
            ovalIn: CGRect(x: sunCenter.x - r, y: sunCenter.y - r, width: r * 2, height: r * 2)
        ).cgPath
    }
}
