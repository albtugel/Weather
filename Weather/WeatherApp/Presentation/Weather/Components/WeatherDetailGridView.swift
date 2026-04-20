import UIKit
import SnapKit

final class WeatherDetailGridView: UIView {
    private let stackView = UIStackView()
    private let averageCard = AverageWeatherCardView()
    private let feelsLikeCard = FeelsLikeWeatherCardView()
    private let windCard = WindWeatherCardView()
    private let uvCard = UVIndexWeatherCardView()
    private let sunsetCard = SunsetWeatherCardView()
    private let humidityCard = HumidityWeatherCardView()
    private let pressureCard = PressureWeatherCardView()
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

    func configure(with current: MockWeatherData.Current) {
        currentWeather = current
        averageCard.configure(with: current)
        feelsLikeCard.configure(with: current)
        windCard.configure(with: current)
        uvCard.configure(with: current)
        sunsetCard.configure(with: current)
        humidityCard.configure(with: current)
        pressureCard.configure(with: current)
    }

    private func setupView() {
        backgroundColor = .clear
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupLayout() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.addArrangedSubview(makeTwoColumnRow(left: averageCard, right: feelsLikeCard))
        stackView.addArrangedSubview(windCard)
        stackView.addArrangedSubview(makeTwoColumnRow(left: uvCard, right: sunsetCard))
        stackView.addArrangedSubview(makeTwoColumnRow(left: humidityCard, right: pressureCard))
    }

    private func makeTwoColumnRow(left: UIView, right: UIView) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [left, right])
        row.axis = .horizontal
        row.alignment = .fill
        row.distribution = .fillEqually
        row.spacing = 8
        return row
    }

    @objc private func temperatureUnitChanged() {
        guard let currentWeather else { return }
        configure(with: currentWeather)
    }
}
