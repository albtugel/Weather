import UIKit
import SnapKit

final class WeatherScreenView: UIView {
    let scrollView = UIScrollView()

    private let contentView = UIView()
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackground()
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBackground()
        setupViews()
        setupLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.frame = bounds
        sunGlowLayer?.frame = bounds
        compactHeaderHeightConstraint?.update(offset: 44 + safeAreaInsets.top)
        compactLocationTopConstraint?.update(offset: safeAreaInsets.top + 8)
    }

    func render(_ state: WeatherViewState) {
        updateBackground(conditionCode: state.backgroundConditionCode)
        renderHeader(state)
        renderForecastContent(state)
    }

    func updateHeaderProgress(for offset: CGFloat) {
        let progress = min(1, max(0, (offset - 60) / 60))
        fullHeaderStack.alpha = 1 - progress
        compactHeaderView.alpha = progress
        compactBlurView.alpha = 1
    }

    private func setupBackground() {
        layer.insertSublayer(backgroundLayer, at: 0)
    }

    private func setupViews() {
        backgroundColor = .clear
        configureScrollView()
        configureCompactHeader()
        configureHeaderContent()
    }

    private func configureScrollView() {
        scrollView.alwaysBounceHorizontal = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureCompactHeader() {
        compactHeaderView.translatesAutoresizingMaskIntoConstraints = false
        compactBlurView.translatesAutoresizingMaskIntoConstraints = false
        compactLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        compactSummaryLabel.translatesAutoresizingMaskIntoConstraints = false
        compactSeparator.translatesAutoresizingMaskIntoConstraints = false

        compactHeaderView.backgroundColor = .clear
        compactHeaderView.alpha = 0

        compactBlurView.alpha = 0
        compactBlurView.isUserInteractionEnabled = false

        compactLocationLabel.font = .systemFont(ofSize: 11, weight: .medium)
        compactLocationLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        compactLocationLabel.textAlignment = .center

        compactSummaryLabel.font = .systemFont(ofSize: 17, weight: .regular)
        compactSummaryLabel.textColor = .white
        compactSummaryLabel.textAlignment = .center
        compactSummaryLabel.numberOfLines = 2

        compactSeparator.backgroundColor = UIColor.white.withAlphaComponent(0.3)
    }

    private func configureHeaderContent() {
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

        configureLocationViews()
        configureMainLabels()
    }

    private func configureLocationViews() {
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        locationIconView.image = UIImage(systemName: "location.fill", withConfiguration: iconConfig)
        locationIconView.tintColor = UIColor.white.withAlphaComponent(0.7)

        locationTypeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        locationTypeLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        locationTypeLabel.textAlignment = .center
    }

    private func configureMainLabels() {
        cityLabel.font = .systemFont(ofSize: 36, weight: .regular)
        cityLabel.textColor = .white
        cityLabel.textAlignment = .center

        temperatureLabel.font = .systemFont(ofSize: 96, weight: .thin)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center

        conditionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        conditionLabel.textColor = .white
        conditionLabel.textAlignment = .center

        highLowLabel.font = .systemFont(ofSize: 16, weight: .regular)
        highLowLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        highLowLabel.textAlignment = .center
    }

    private func setupLayout() {
        layoutContainers()
        layoutHeaderSection()
        layoutForecastSection()
        layoutCompactHeaderSection()
    }

    private func layoutContainers() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        addSubview(compactHeaderView)
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
    }

    private func layoutHeaderSection() {
        let locationStack = makeLocationStack()
        configureFullHeaderStack(with: locationStack)

        contentView.addSubview(headerContainer)
        headerContainer.addSubview(fullHeaderStack)

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

        fullHeaderStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().offset(-24)
        }
    }

    private func layoutForecastSection() {
        contentView.addSubview(hourlyCard)
        contentView.addSubview(tenDayCard)
        contentView.addSubview(detailGrid)

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
    }

    private func layoutCompactHeaderSection() {
        compactHeaderView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            compactHeaderHeightConstraint = make.height.equalTo(44 + safeAreaInsets.top).constraint
        }

        compactBlurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        compactLocationLabel.snp.makeConstraints { make in
            compactLocationTopConstraint = make.top.equalToSuperview().offset(safeAreaInsets.top + 8).constraint
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

    private func makeLocationStack() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [locationIconView, locationTypeLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    private func configureFullHeaderStack(with locationStack: UIStackView) {
        fullHeaderStack.axis = .vertical
        fullHeaderStack.alignment = .center
        fullHeaderStack.spacing = 0
        fullHeaderStack.translatesAutoresizingMaskIntoConstraints = false
        fullHeaderStack.alpha = 1

        fullHeaderStack.addArrangedSubview(locationStack)
        fullHeaderStack.addArrangedSubview(cityLabel)
        fullHeaderStack.addArrangedSubview(temperatureLabel)
        fullHeaderStack.addArrangedSubview(conditionLabel)
        fullHeaderStack.addArrangedSubview(highLowLabel)

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        fullHeaderStack.addArrangedSubview(spacer)
        fullHeaderStack.setCustomSpacing(2, after: conditionLabel)
    }

    private func updateBackground(conditionCode: Int) {
        let background = WeatherBackground.current(conditionCode: conditionCode)
        backgroundLayer.colors = background.gradientColors
        backgroundLayer.locations = background.locations
        backgroundLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        sunGlowLayer?.removeFromSuperlayer()
        sunGlowLayer = background.sunGlowLayer(in: bounds)
        if let sunGlowLayer {
            layer.insertSublayer(sunGlowLayer, above: backgroundLayer)
        }
    }

    private func renderHeader(_ state: WeatherViewState) {
        let locationAttributes: [NSAttributedString.Key: Any] = [.kern: 2.0]
        locationTypeLabel.attributedText = NSAttributedString(string: state.locationText, attributes: locationAttributes)
        compactLocationLabel.text = "▼ \(state.locationText)"
        cityLabel.text = state.cityName
        temperatureLabel.text = state.temperatureText
        conditionLabel.text = state.conditionText
        highLowLabel.text = state.highLowText
        compactSummaryLabel.text = state.compactSummaryText
    }

    private func renderForecastContent(_ state: WeatherViewState) {
        hourlyCard.configure(with: state.hourlyItems, summary: state.currentWeather.forecastSummary)
        tenDayCard.configure(with: state.dailyItems)
        detailGrid.configure(with: state.currentWeather)
    }
}
