import UIKit
import SnapKit

final class HourlyForecastCard: UIView {
    private let summaryLabel = UILabel()
    private let separatorView = UIView()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var hourItems: [MockWeatherData.HourlyWeather] = []

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

        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.text = nil
        summaryLabel.font = .systemFont(ofSize: 14, weight: .regular)
        summaryLabel.textColor = .white
        summaryLabel.numberOfLines = 2
        summaryLabel.textAlignment = .left

        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor.white.withAlphaComponent(0.3)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 0
    }

    private func setupLayout() {
        addSubview(summaryLabel)
        addSubview(separatorView)
        addSubview(scrollView)
        scrollView.addSubview(stackView)

        summaryLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        separatorView.snp.makeConstraints { make in
            make.top.equalTo(summaryLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(90)
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.height.equalToSuperview()
        }
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    func configure(with items: [MockWeatherData.HourlyWeather], summary: String) {
        summaryLabel.text = summary
        hourItems = items
        rebuildHours()
    }

    private func rebuildHours() {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        hourItems.forEach { item in
            stackView.addArrangedSubview(makeCell(for: item))
        }
    }

    private func makeCell(for item: MockWeatherData.HourlyWeather) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.snp.makeConstraints { make in
            make.width.equalTo(52)
            make.height.equalTo(80)
        }

        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.text = item.label
        timeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center

        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        iconView.image = UIImage(systemName: item.icon, withConfiguration: iconConfig)
        iconView.tintColor = item.isSunset ? UIColor.systemOrange : .white
        iconView.contentMode = .scaleAspectFit

        let tempLabel = UILabel()
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        if item.isSunset {
            tempLabel.text = "Закат"
        } else if let temp = item.temp {
            tempLabel.text = Double(temp).formatted(unit: AppSettings.shared.temperatureUnit)
        } else {
            tempLabel.text = ""
        }
        tempLabel.font = .systemFont(ofSize: 16, weight: .medium)
        tempLabel.textColor = .white
        tempLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [timeLabel, iconView, tempLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4

        container.addSubview(stack)

        iconView.snp.makeConstraints { make in
            make.size.equalTo(28)
        }

        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        return container
    }

    @objc private func temperatureUnitChanged() {
        rebuildHours()
    }
}
