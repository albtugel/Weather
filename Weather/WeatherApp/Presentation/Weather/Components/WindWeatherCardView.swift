import UIKit
import SnapKit

final class WindWeatherCardView: WeatherCardContainerView {
    private let windRow = WindValueRowView()
    private let gustRow = WindValueRowView()
    private let directionRow = WindValueRowView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(with current: MockWeatherData.Current) {
        windRow.configure(title: "Ветер", value: "\(current.windSpeed) км/ч")
        gustRow.configure(title: "Порывы ветра", value: "\(current.windGust) км/ч")
        directionRow.configure(title: "Направление", value: current.windDirection)
    }

    private func setupView() {
        let stack = UIStackView(arrangedSubviews: [
            makeHeaderRow(iconName: "wind", title: "ВЕТЕР"),
            windRow,
            makeSeparator(alpha: 0.2),
            gustRow,
            makeSeparator(alpha: 0.2),
            directionRow
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8
        embedContent(stack)
    }
}

private final class WindValueRowView: UIView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }

    private func setupView() {
        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = .white

        valueLabel.font = .systemFont(ofSize: 16, weight: .regular)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .right
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
