import UIKit
import SnapKit

final class SunsetWeatherCardView: WeatherCardContainerView {
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
        valueLabel.text = WeatherDetailFormatting.timeString(from: current.sunset)
        subtitleLabel.text = "Восход в \(WeatherDetailFormatting.timeString(from: current.sunrise))."
    }

    private func setupView() {
        valueLabel.font = .systemFont(ofSize: 28, weight: .medium)
        valueLabel.textColor = .white

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)

        let arcView = SunArcView()
        arcView.snp.makeConstraints { make in
            make.height.equalTo(60)
        }

        let stack = UIStackView(arrangedSubviews: [
            makeHeaderRow(iconName: "sunset.fill", title: "ЗАКАТ"),
            valueLabel,
            subtitleLabel,
            makeSpacer(),
            arcView
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8
        embedContent(stack)
    }
}

private final class SunArcView: UIView {
    private let arcLayer = CAShapeLayer()
    private let sunLayer = CAShapeLayer()

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
        arcLayer.fillColor = UIColor.clear.cgColor
        arcLayer.lineWidth = 2
        sunLayer.fillColor = UIColor.white.cgColor
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
        let radiusValue: CGFloat = 4
        sunLayer.path = UIBezierPath(
            ovalIn: CGRect(
                x: sunCenter.x - radiusValue,
                y: sunCenter.y - radiusValue,
                width: radiusValue * 2,
                height: radiusValue * 2
            )
        ).cgPath
    }
}
