import UIKit
import SnapKit
import Combine

final class WeatherViewController: UIViewController {
    private let viewModel = WeatherViewModel()
    private let mockWeather = MockWeatherData.current
    private var liveWeather: Weather?
    private var cancellables = Set<AnyCancellable>()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let tabBar = WeatherTabBar()
    private var tabBarHeightConstraint: Constraint?

    private let compactHeaderView = UIView()
    private let compactBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    private let compactLocationLabel = UILabel()
    private let compactSummaryLabel = UILabel()
    private let compactSeparator = UIView()
    private var compactHeaderHeightConstraint: Constraint?
    private var compactLocationTopConstraint: Constraint?

    private let headerContainer = UIView()
    private let fullHeaderStack = UIStackView()
    private let hourlyCard = HourlyForecastCard()
    private let tenDayCard = TenDayForecastCard()
    private let detailGrid = WeatherDetailGridView()

    private let locationIconView = UIImageView()
    private let locationTypeLabel = UILabel()
    private let cityLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let conditionLabel = UILabel()
    private let highLowLabel = UILabel()

    private let backgroundLayer = CAGradientLayer()
    private var sunGlowLayer: CARadialGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupViews()
        setupLayout()
        configureCards()
        bindViewModel()
        viewModel.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(temperatureUnitChanged),
            name: .temperatureUnitChanged,
            object: nil
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundLayer.frame = view.bounds
        sunGlowLayer?.frame = view.bounds
        let height = 49 + view.safeAreaInsets.bottom
        tabBarHeightConstraint?.update(offset: height)
        compactHeaderHeightConstraint?.update(offset: 44 + view.safeAreaInsets.top)
        compactLocationTopConstraint?.update(offset: view.safeAreaInsets.top + 8)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("scrollView.contentSize: \(scrollView.contentSize)")
    }

    private func setupBackground() {
        let background = WeatherBackground.current(conditionCode: mockWeather.conditionCode)
        backgroundLayer.colors = background.gradientColors
        backgroundLayer.locations = background.locations
        backgroundLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(backgroundLayer, at: 0)

        sunGlowLayer = background.sunGlowLayer(in: view.bounds)
        if let sunGlowLayer {
            view.layer.insertSublayer(sunGlowLayer, above: backgroundLayer)
        }
    }

    private func setupViews() {
        view.backgroundColor = .clear

        scrollView.alwaysBounceHorizontal = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        contentView.translatesAutoresizingMaskIntoConstraints = false
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        compactHeaderView.translatesAutoresizingMaskIntoConstraints = false
        compactBlurView.translatesAutoresizingMaskIntoConstraints = false
        compactLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        compactSummaryLabel.translatesAutoresizingMaskIntoConstraints = false
        compactSeparator.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        hourlyCard.translatesAutoresizingMaskIntoConstraints = false
        tenDayCard.translatesAutoresizingMaskIntoConstraints = false
        detailGrid.translatesAutoresizingMaskIntoConstraints = false

        locationIconView.translatesAutoresizingMaskIntoConstraints = false
        locationTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        conditionLabel.translatesAutoresizingMaskIntoConstraints = false
        highLowLabel.translatesAutoresizingMaskIntoConstraints = false

        let iconConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        locationIconView.image = UIImage(systemName: "location.fill", withConfiguration: iconConfig)
        locationIconView.tintColor = UIColor.white.withAlphaComponent(0.7)

        setLocationType(text: mockWeather.locationType)
        locationTypeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        locationTypeLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        locationTypeLabel.textAlignment = .center

        cityLabel.text = mockWeather.cityName
        cityLabel.font = .systemFont(ofSize: 36, weight: .regular)
        cityLabel.textColor = .white
        cityLabel.textAlignment = .center

        temperatureLabel.text = Double(mockWeather.temperature).formatted(unit: AppSettings.shared.temperatureUnit)
        temperatureLabel.font = .systemFont(ofSize: 96, weight: .thin)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center

        conditionLabel.text = mockWeather.description
        conditionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        conditionLabel.textColor = .white
        conditionLabel.textAlignment = .center

        let high = Double(mockWeather.high).formatted(unit: AppSettings.shared.temperatureUnit)
        let low = Double(mockWeather.low).formatted(unit: AppSettings.shared.temperatureUnit)
        highLowLabel.text = "Макс.: \(high), мин.: \(low)"
        highLowLabel.font = .systemFont(ofSize: 16, weight: .regular)
        highLowLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        highLowLabel.textAlignment = .center

        compactHeaderView.backgroundColor = .clear
        compactHeaderView.alpha = 0

        compactBlurView.alpha = 0
        compactBlurView.isUserInteractionEnabled = false

        compactLocationLabel.font = .systemFont(ofSize: 11, weight: .medium)
        compactLocationLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        compactLocationLabel.textAlignment = .center

        let tempText = Double(mockWeather.temperature).formatted(unit: AppSettings.shared.temperatureUnit)
        compactSummaryLabel.text = "\(mockWeather.cityName)  \(tempText) | \(mockWeather.description)"
        compactSummaryLabel.font = .systemFont(ofSize: 17, weight: .regular)
        compactSummaryLabel.textColor = .white
        compactSummaryLabel.textAlignment = .center
        compactSummaryLabel.numberOfLines = 2

        compactSeparator.backgroundColor = UIColor.white.withAlphaComponent(0.3)

        tabBar.onMapTap = { [weak self] in
            self?.mapButtonTapped()
        }
    }

    private func bindViewModel() {
        viewModel.$weather
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] weather in
                self?.applyLiveWeather(weather)
            }
            .store(in: &cancellables)
    }

    private func applyLiveWeather(_ weather: Weather) {
        liveWeather = weather
        let locationText = "ТЕКУЩЕЕ МЕСТО"
        setLocationType(text: locationText)
        cityLabel.text = weather.cityName
        let tempText = weather.temperature.formatted(unit: AppSettings.shared.temperatureUnit)
        temperatureLabel.text = tempText
        conditionLabel.text = weather.description
        let high = weather.tempMax.formatted(unit: AppSettings.shared.temperatureUnit)
        let low = weather.tempMin.formatted(unit: AppSettings.shared.temperatureUnit)
        highLowLabel.text = "Макс.: \(high), мин.: \(low)"
        compactSummaryLabel.text = "\(weather.cityName)  \(tempText) | \(weather.description)"
    }

    private func setLocationType(text: String) {
        let locationAttributed = NSAttributedString(
            string: text,
            attributes: [
                .kern: 2.0
            ]
        )
        locationTypeLabel.attributedText = locationAttributed
        compactLocationLabel.text = "▼ \(text)"
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(tabBar)
        view.addSubview(compactHeaderView)
        compactHeaderView.addSubview(compactBlurView)
        compactHeaderView.addSubview(compactLocationLabel)
        compactHeaderView.addSubview(compactSummaryLabel)
        compactHeaderView.addSubview(compactSeparator)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        let locationStack = UIStackView(arrangedSubviews: [locationIconView, locationTypeLabel])
        locationStack.axis = .horizontal
        locationStack.alignment = .center
        locationStack.spacing = 8
        locationStack.translatesAutoresizingMaskIntoConstraints = false

        fullHeaderStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        fullHeaderStack.axis = .vertical
        fullHeaderStack.alignment = .center
        fullHeaderStack.spacing = 0
        fullHeaderStack.translatesAutoresizingMaskIntoConstraints = false
        fullHeaderStack.alpha = 1

        let headerStack = fullHeaderStack
        headerStack.addArrangedSubview(locationStack)
        headerStack.addArrangedSubview(cityLabel)
        headerStack.addArrangedSubview(temperatureLabel)
        headerStack.addArrangedSubview(conditionLabel)
        headerStack.addArrangedSubview(highLowLabel)

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        headerStack.addArrangedSubview(spacer)

        headerStack.setCustomSpacing(2, after: conditionLabel)

        contentView.addSubview(headerContainer)
        headerContainer.addSubview(headerStack)
        contentView.addSubview(hourlyCard)
        contentView.addSubview(tenDayCard)
        contentView.addSubview(detailGrid)

        locationStack.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        locationIconView.snp.makeConstraints { make in
            make.size.equalTo(10)
        }

        headerContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(59)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(320)
        }

        headerStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().offset(-24)
        }

        hourlyCard.snp.makeConstraints { make in
            make.top.equalTo(headerContainer.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(160)
        }

        tenDayCard.snp.makeConstraints { make in
            make.top.equalTo(hourlyCard.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(500)
        }

        detailGrid.snp.makeConstraints { make in
            make.top.equalTo(tenDayCard.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-40)
            make.height.greaterThanOrEqualTo(636)
        }

        tabBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            tabBarHeightConstraint = make.height.equalTo(49 + view.safeAreaInsets.bottom).constraint
        }

        compactHeaderView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            compactHeaderHeightConstraint = make.height.equalTo(44 + view.safeAreaInsets.top).constraint
        }

        compactBlurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        compactLocationLabel.snp.makeConstraints { make in
            compactLocationTopConstraint = make.top.equalToSuperview().offset(view.safeAreaInsets.top + 8).constraint
            make.leading.trailing.equalToSuperview().inset(20)
        }

        compactSummaryLabel.snp.makeConstraints { make in
            make.top.equalTo(compactLocationLabel.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        compactSeparator.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    private func configureCards() {
        hourlyCard.configure(with: MockWeatherData.hourly, summary: mockWeather.forecastSummary)
        tenDayCard.configure(with: MockWeatherData.daily)
        detailGrid.configure(with: mockWeather)
    }

    @objc private func temperatureUnitChanged() {
        if let weather = liveWeather {
            applyLiveWeather(weather)
        } else {
            let unit = AppSettings.shared.temperatureUnit
            temperatureLabel.text = Double(mockWeather.temperature).formatted(unit: unit)
            let high = Double(mockWeather.high).formatted(unit: unit)
            let low = Double(mockWeather.low).formatted(unit: unit)
            highLowLabel.text = "Макс.: \(high), мин.: \(low)"
            let tempText = Double(mockWeather.temperature).formatted(unit: unit)
            compactSummaryLabel.text = "\(mockWeather.cityName)  \(tempText) | \(mockWeather.description)"
        }
        configureCards()
    }

    @objc private func mapButtonTapped() {
        guard let url = URL(string: "maps://") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

extension WeatherViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let progress = min(1, max(0, (offset - 60) / 60))
        fullHeaderStack.alpha = 1 - progress
        compactHeaderView.alpha = progress
        compactBlurView.alpha = 1
    }
}
