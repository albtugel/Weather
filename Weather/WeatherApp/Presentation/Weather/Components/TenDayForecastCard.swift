import UIKit
import SnapKit

final class TenDayForecastCard: UIView {
    private let headerIconView = UIImageView()
    private let headerLabel = UILabel()
    private let headerSeparator = UIView()
    private let stackView = UIStackView()
    private var items: [MockWeatherData.DailyWeather] = []

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
        backgroundColor = UIColor.white.withAlphaComponent(0.15)
        layer.cornerRadius = 16
        clipsToBounds = true

        let iconConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        headerIconView.image = UIImage(systemName: "calendar", withConfiguration: iconConfig)
        headerIconView.tintColor = UIColor.white.withAlphaComponent(0.6)
        headerIconView.translatesAutoresizingMaskIntoConstraints = false

        let headerText = "ПРОГНОЗ НА 10 ДНЕЙ"
        headerLabel.attributedText = NSAttributedString(
            string: headerText,
            attributes: [
                .kern: 1.0
            ]
        )
        headerLabel.font = .systemFont(ofSize: 12, weight: .medium)
        headerLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        headerSeparator.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        headerSeparator.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupLayout() {
        addSubview(headerIconView)
        addSubview(headerLabel)
        addSubview(headerSeparator)
        addSubview(stackView)

        headerIconView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
            make.size.equalTo(12)
        }

        headerLabel.snp.makeConstraints { make in
            make.centerY.equalTo(headerIconView.snp.centerY)
            make.leading.equalTo(headerIconView.snp.trailing).offset(6)
            make.trailing.lessThanOrEqualToSuperview().offset(-12)
        }

        headerSeparator.snp.makeConstraints { make in
            make.top.equalTo(headerIconView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(0.5)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(headerSeparator.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func configure(with items: [MockWeatherData.DailyWeather]) {
        self.items = items
        rebuildRows()
    }

    private func rebuildRows() {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let minTemp = items.map { $0.low }.min() ?? 0
        let maxTemp = items.map { $0.high }.max() ?? 1

        for index in items.indices {
            let row = TenDayForecastRowView(
                item: items[index],
                minTemp: minTemp,
                maxTemp: maxTemp
            )
            stackView.addArrangedSubview(row)

            if index != items.indices.last {
                stackView.addArrangedSubview(RowSeparatorView())
            }
        }
    }

    @objc private func temperatureUnitChanged() {
        rebuildRows()
    }
}

private final class RowSeparatorView: UIView {
    private let line = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor.white.withAlphaComponent(0.15)

        addSubview(line)

        snp.makeConstraints { make in
            make.height.equalTo(0.5)
        }
        line.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}

private final class TenDayForecastRowView: UIView {
    private let dayLabel = UILabel()
    private let iconView = UIImageView()
    private let lowLabel = UILabel()
    private let highLabel = UILabel()
    private let barTrack = UIView()
    private let barFill = UIView()
    private let barFillGradient = CAGradientLayer()

    private let minTemp: Int
    private let maxTemp: Int
    private let lowTemp: Int
    private let highTemp: Int

    init(item: MockWeatherData.DailyWeather, minTemp: Int, maxTemp: Int) {
        self.minTemp = minTemp
        self.maxTemp = maxTemp
        self.lowTemp = item.low
        self.highTemp = item.high
        super.init(frame: .zero)
        setupView(item: item)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        self.minTemp = 0
        self.maxTemp = 1
        self.lowTemp = 0
        self.highTemp = 1
        super.init(coder: coder)
        setupView(item: .init(day: "", icon: "sun.max.fill", low: 0, high: 1))
        setupLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutBarFill()
    }

    private func setupView(item: MockWeatherData.DailyWeather) {
        translatesAutoresizingMaskIntoConstraints = false
        snp.makeConstraints { make in
            make.height.equalTo(44)
        }

        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.text = item.day
        dayLabel.font = .systemFont(ofSize: 16, weight: .medium)
        dayLabel.textColor = .white

        iconView.translatesAutoresizingMaskIntoConstraints = false
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        iconView.image = UIImage(systemName: item.icon, withConfiguration: iconConfig)
        iconView.tintColor = .white

        lowLabel.translatesAutoresizingMaskIntoConstraints = false
        lowLabel.text = Double(item.low).formatted(unit: AppSettings.shared.temperatureUnit)
        lowLabel.font = .systemFont(ofSize: 14, weight: .regular)
        lowLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        lowLabel.textAlignment = .right

        highLabel.translatesAutoresizingMaskIntoConstraints = false
        highLabel.text = Double(item.high).formatted(unit: AppSettings.shared.temperatureUnit)
        highLabel.font = .systemFont(ofSize: 16, weight: .medium)
        highLabel.textColor = .white
        highLabel.textAlignment = .right

        barTrack.translatesAutoresizingMaskIntoConstraints = false
        barTrack.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        barTrack.layer.cornerRadius = 2

        barFill.translatesAutoresizingMaskIntoConstraints = false
        barFill.layer.cornerRadius = 2
        barFill.clipsToBounds = true
        barFillGradient.colors = [
            UIColor(hex: "#4cd964").cgColor,
            UIColor(hex: "#4cd964").cgColor
        ]
        barFill.layer.addSublayer(barFillGradient)
    }

    private func setupLayout() {
        addSubview(dayLabel)
        addSubview(iconView)
        addSubview(lowLabel)
        addSubview(barTrack)
        addSubview(barFill)
        addSubview(highLabel)

        dayLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(65)
        }

        iconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-60)
            make.centerY.equalToSuperview()
            make.size.equalTo(22)
        }

        highLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(35)
        }

        barTrack.snp.makeConstraints { make in
            make.trailing.equalTo(highLabel.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.height.equalTo(4)
            make.width.equalTo(120)
        }

        lowLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(barTrack.snp.leading).offset(-8)
            make.width.equalTo(35)
        }
    }

    private func layoutBarFill() {
        let trackFrame = barTrack.frame
        let range = max(maxTemp - minTemp, 1)
        let startRatio = CGFloat(lowTemp - minTemp) / CGFloat(range)
        let endRatio = CGFloat(highTemp - minTemp) / CGFloat(range)

        let startX = trackFrame.minX + trackFrame.width * startRatio
        let width = max(trackFrame.width * (endRatio - startRatio), 0)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        barFill.frame = CGRect(x: startX, y: trackFrame.minY, width: width, height: trackFrame.height)
        barFillGradient.frame = barFill.bounds
        barFillGradient.cornerRadius = 2
        
        CATransaction.commit()
    }
}

private extension UIColor {
    convenience init(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") {
            cleaned.removeFirst()
        }

        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
