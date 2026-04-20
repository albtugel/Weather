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
        setupObservers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupLayout()
        setupObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(temperatureUnitChanged),
            name: .temperatureUnitChanged,
            object: nil
        )
    }

    private func setupView() {
        backgroundColor = UIColor.white.withAlphaComponent(0.15)
        layer.cornerRadius = 16
        clipsToBounds = true

        let iconConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        headerIconView.image = UIImage(systemName: "calendar", withConfiguration: iconConfig)
        headerIconView.tintColor = UIColor.white.withAlphaComponent(0.6)

        headerLabel.font = .systemFont(ofSize: 12, weight: .medium)
        headerLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        headerLabel.attributedText = NSAttributedString(
            string: "ПРОГНОЗ НА 10 ДНЕЙ",
            attributes: [.kern: 1.0]
        )

        headerSeparator.backgroundColor = UIColor.white.withAlphaComponent(0.2)

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 0
    }

    private func setupLayout() {
        [headerIconView, headerLabel, headerSeparator, stackView].forEach { addSubview($0) }

        headerIconView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
            make.size.equalTo(12)
        }

        headerLabel.snp.makeConstraints { make in
            make.centerY.equalTo(headerIconView.snp.centerY)
            make.leading.equalTo(headerIconView.snp.trailing).offset(6)
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
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let minTemp = items.map { $0.low }.min() ?? 0
        let maxTemp = items.map { $0.high }.max() ?? 1

        for (index, item) in items.enumerated() {
            let row = TenDayForecastRowView(item: item, minTemp: minTemp, maxTemp: maxTemp)
            stackView.addArrangedSubview(row)

            if index != items.count - 1 {
                stackView.addArrangedSubview(RowSeparatorView())
            }
        }
    }

    @objc private func temperatureUnitChanged() {
        rebuildRows()
    }
}
