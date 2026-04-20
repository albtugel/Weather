import UIKit
import SnapKit

final class TenDayForecastRowView: UIView {
    private static let coldColor = UIColor(hex: "#63c7ff")
    private static let warmColor = UIColor(hex: "#ff9f45")

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

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutBarFill()
    }

    private func setupView(item: MockWeatherData.DailyWeather) {
        snp.makeConstraints { make in make.height.equalTo(44) }

        dayLabel.text = item.day
        dayLabel.font = .systemFont(ofSize: 16, weight: .medium)
        dayLabel.textColor = .white

        let iconConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        iconView.image = UIImage(systemName: item.icon, withConfiguration: iconConfig)
        iconView.tintColor = .white

        lowLabel.text = Double(item.low).formatted(unit: AppSettings.shared.temperatureUnit)
        lowLabel.font = .systemFont(ofSize: 14, weight: .regular)
        lowLabel.textColor = .white.withAlphaComponent(0.6)
        lowLabel.textAlignment = .right

        highLabel.text = Double(item.high).formatted(unit: AppSettings.shared.temperatureUnit)
        highLabel.font = .systemFont(ofSize: 16, weight: .medium)
        highLabel.textColor = .white
        highLabel.textAlignment = .right

        barTrack.backgroundColor = .white.withAlphaComponent(0.2)
        barTrack.layer.cornerRadius = 2

        barFill.layer.cornerRadius = 2
        barFill.clipsToBounds = true
        barFillGradient.startPoint = CGPoint(x: 0, y: 0.5)
        barFillGradient.endPoint = CGPoint(x: 1, y: 0.5)
        barFill.layer.addSublayer(barFillGradient)
    }

    private func setupLayout() {
        [dayLabel, iconView, lowLabel, barTrack, barFill, highLabel].forEach { addSubview($0) }

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
        barFillGradient.colors = [
            color(for: startRatio).cgColor,
            color(for: endRatio).cgColor
        ]
        CATransaction.commit()
    }

    private func color(for ratio: CGFloat) -> UIColor {
        let clampedRatio = min(max(ratio, 0), 1)

        var coldRed: CGFloat = 0
        var coldGreen: CGFloat = 0
        var coldBlue: CGFloat = 0
        var coldAlpha: CGFloat = 0
        TenDayForecastRowView.coldColor.getRed(&coldRed, green: &coldGreen, blue: &coldBlue, alpha: &coldAlpha)

        var warmRed: CGFloat = 0
        var warmGreen: CGFloat = 0
        var warmBlue: CGFloat = 0
        var warmAlpha: CGFloat = 0
        TenDayForecastRowView.warmColor.getRed(&warmRed, green: &warmGreen, blue: &warmBlue, alpha: &warmAlpha)

        return UIColor(
            red: coldRed + (warmRed - coldRed) * clampedRatio,
            green: coldGreen + (warmGreen - coldGreen) * clampedRatio,
            blue: coldBlue + (warmBlue - coldBlue) * clampedRatio,
            alpha: coldAlpha + (warmAlpha - coldAlpha) * clampedRatio
        )
    }
}
