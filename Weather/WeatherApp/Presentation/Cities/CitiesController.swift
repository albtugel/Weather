import Combine
import CoreLocation
import MapKit
import SnapKit
import UIKit

final class CitiesController: UIViewController {
    var onCitySelected: ((City) -> Void)?

    private let backgroundLayer = CAGradientLayer()
    private var sunGlowLayer: CARadialGradientLayer?
    private let titleLabel = UILabel()
    private let infoLabel = UILabel()
    private let searchField = SearchField()
    private let tableView = UITableView(frame: .zero, style: .plain)

    private let store: CityStore
    private let lookup: CityLookup
    private let locationManager: LocationManagerProtocol
    private let getWeather: GetWeatherUseCaseProtocol

    private let query = CurrentValueSubject<String, Never>("")
    private var rows: [Row] = []
    private var cities: [CityCard] = []
    private var results: [SearchResult] = []
    private var cancellables = Set<AnyCancellable>()

    init(
        store: CityStore = DIContainer.shared.cityStore,
        lookup: CityLookup = DIContainer.shared.cityLookup,
        locationManager: LocationManagerProtocol = DIContainer.shared.locationManager,
        getWeather: GetWeatherUseCaseProtocol = DIContainer.shared.getWeatherUseCase
    ) {
        self.store = store
        self.lookup = lookup
        self.locationManager = locationManager
        self.getWeather = getWeather
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.store = DIContainer.shared.cityStore
        self.lookup = DIContainer.shared.cityLookup
        self.locationManager = DIContainer.shared.locationManager
        self.getWeather = DIContainer.shared.getWeatherUseCase
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
        bind()
        reloadCities()
        locationManager.requestLocation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundLayer.frame = view.bounds
        sunGlowLayer?.frame = view.bounds
    }

    private func setupViews() {
        setupBackground(conditionCode: MockWeatherData.current.conditionCode)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = ""
        navigationItem.hidesBackButton = true

        titleLabel.text = "Погода"
        titleLabel.font = .systemFont(ofSize: 40, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left

        infoLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        infoLabel.textColor = UIColor.white.withAlphaComponent(0.46)
        infoLabel.textAlignment = .center

        searchField.onChange = { [weak self] text in
            self?.query.send(text)
        }

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 0)
        tableView.register(WeatherCityCell.self, forCellReuseIdentifier: WeatherCityCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupBackground(conditionCode: Int) {
        let background = WeatherBackground.current(conditionCode: conditionCode)
        backgroundLayer.colors = background.gradientColors
        backgroundLayer.locations = background.locations
        backgroundLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(backgroundLayer, at: 0)

        sunGlowLayer?.removeFromSuperlayer()
        sunGlowLayer = background.sunGlowLayer(in: view.bounds)
        if let sunGlowLayer {
            view.layer.insertSublayer(sunGlowLayer, above: backgroundLayer)
        }
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(infoLabel)
        view.addSubview(searchField)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(28)
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().offset(-28)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(26)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(infoLabel.snp.top).offset(-8)
        }

        infoLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(28)
            make.bottom.equalTo(searchField.snp.top).offset(-22)
        }

        searchField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(28)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-18)
            make.height.equalTo(54)
        }
    }

    private func bind() {
        query
            .debounce(for: .milliseconds(350), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.search(text)
            }
            .store(in: &cancellables)

        lookup.results
            .dropFirst()
            .sink { [weak self] completions in
                self?.showResults(completions)
            }
            .store(in: &cancellables)

        lookup.errors
            .sink { [weak self] _ in
                self?.showSearchError()
            }
            .store(in: &cancellables)

        locationManager.statusPublisher
            .sink { [weak self] status in
                self?.handleLocation(status)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .temperatureUnitChanged)
            .sink { [weak self] _ in
                self?.reloadCities()
            }
            .store(in: &cancellables)
    }

    private func search(_ text: String) {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            lookup.clear()
            showSavedCities()
            return
        }

        rows = cityRows() + [.message("Ищем города")]
        tableView.reloadData()
        lookup.search(query)
    }

    private func showResults(_ completions: [MKLocalSearchCompletion]) {
        guard hasActiveQuery else { return }

        results = completions.map {
            SearchResult(title: $0.title, subtitle: $0.subtitle, completion: $0)
        }

        rows = cityRows() + (results.isEmpty ? [.message("Ничего не найдено")] : results.map { .result($0) })
        tableView.reloadData()
    }

    private func showMessage(_ text: String) {
        rows = cityRows() + [.message(text)]
        tableView.reloadData()
    }

    private func showSearchError() {
        guard hasActiveQuery else { return }
        showMessage("Поиск сейчас недоступен")
    }

    private func handleLocation(_ status: LocationStatus) {
        guard case let .authorized(location) = status else { return }

        store.upsert(
            City(
                id: City.currentId,
                name: "Текущее место",
                subtitle: nil,
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude,
                isCurrent: true
            )
        )

        reloadCities()
    }

    private func reloadCities() {
        let savedCities = store.all()
        cities = savedCities.map {
            CityCard(city: $0, temperature: "--°", condition: "Загрузка", highLow: "")
        }
        showSavedCities()
        tableView.reloadData()

        Task { [weak self] in
            await self?.loadWeather(for: savedCities)
        }
    }

    private func loadWeather(for savedCities: [City]) async {
        var loaded: [CityCard] = []
        let unit = AppSettings.shared.temperatureUnit

        for city in savedCities {
            do {
                let weather = try await getWeather.execute(lat: city.lat, lon: city.lon)
                loaded.append(
                    CityCard(
                        city: city,
                        temperature: weather.temperature.formatted(unit: unit),
                        condition: weather.description,
                        highLow: "Макс.: \(weather.tempMax.formatted(unit: unit))  Мин.: \(weather.tempMin.formatted(unit: unit))"
                    )
                )
            } catch {
                loaded.append(
                    CityCard(city: city, temperature: "--°", condition: "Нет данных", highLow: "")
                )
            }
        }

        cities = loaded

        if case .city = rows.first {
            rows = cityRows() + resultRowsForActiveQuery()
            tableView.reloadData()
        }
    }

    private func addCity(from result: SearchResult) {
        Task { [weak self] in
            guard let self else { return }

            do {
                let city = try await lookup.city(from: result.completion)
                store.upsert(city)
                searchField.clear()
                reloadCities()
            } catch {
                showMessage("Не удалось добавить город")
            }
        }
    }

    private var hasActiveQuery: Bool {
        !query.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func showSavedCities() {
        rows = cities.isEmpty ? [.message("Разрешите геолокацию или добавьте город через поиск")] : cityRows()
        tableView.reloadData()
    }

    private func cityRows() -> [Row] {
        cities.map { .city($0) }
    }

    private func resultRowsForActiveQuery() -> [Row] {
        guard hasActiveQuery else { return [] }
        return results.isEmpty ? [.message("Ничего не найдено")] : results.map { .result($0) }
    }
}

extension CitiesController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch rows[indexPath.row] {
        case let .city(card):
            return cityCell(card)
        case let .result(result):
            return resultCell(result)
        case let .message(text):
            return messageCell(text)
        }
    }
}

extension CitiesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch rows[indexPath.row] {
        case let .city(card):
            onCitySelected?(card.city)
        case let .result(result):
            addCity(from: result)
        case .message:
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch rows[indexPath.row] {
        case .city:
            return 112
        case .result:
            return 62
        case .message:
            return 64
        }
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard case let .city(card) = rows[indexPath.row], !card.city.isCurrent else {
            return nil
        }

        let delete = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            self?.store.remove(id: card.city.id)
            self?.reloadCities()
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [delete])
    }
}

private extension CitiesController {
    func cityCell(_ card: CityCard) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeatherCityCell.reuseId) as? WeatherCityCell else {
            return UITableViewCell()
        }

        cell.render(card)
        cell.selectionStyle = .none
        return cell
    }

    func resultCell(_ result: SearchResult) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(systemName: "mappin.circle.fill")
        content.text = result.title
        content.secondaryText = result.subtitle
        content.imageProperties.tintColor = UIColor.white.withAlphaComponent(0.76)
        content.textProperties.color = .white
        content.secondaryTextProperties.color = UIColor.white.withAlphaComponent(0.65)
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }

    func messageCell(_ text: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        var content = cell.defaultContentConfiguration()
        content.text = text
        content.textProperties.alignment = .center
        content.textProperties.color = UIColor.white.withAlphaComponent(0.7)
        content.textProperties.font = .systemFont(ofSize: 16, weight: .medium)
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }

    enum Row {
        case city(CityCard)
        case result(SearchResult)
        case message(String)
    }

    struct CityCard {
        let city: City
        let temperature: String
        let condition: String
        let highLow: String
    }

    struct SearchResult {
        let title: String
        let subtitle: String
        let completion: MKLocalSearchCompletion
    }
}

private final class WeatherCityCell: UITableViewCell {
    static let reuseId = "WeatherCityCell"

    private let cardView = UIView()
    private let cityLabel = UILabel()
    private let locationLabel = UILabel()
    private let conditionLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let highLowLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupLayout()
    }

    func render(_ card: CitiesController.CityCard) {
        cityLabel.text = card.city.name
        locationLabel.text = card.city.isCurrent ? "Моя геопозиция  •  Дом" : card.city.subtitle
        conditionLabel.text = card.condition.capitalized
        temperatureLabel.text = card.temperature
        highLowLabel.text = card.highLow
    }

    private func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        cardView.layer.cornerRadius = 16
        cardView.layer.cornerCurve = .continuous

        cityLabel.font = .systemFont(ofSize: 21, weight: .semibold)
        cityLabel.textColor = .white

        locationLabel.font = .systemFont(ofSize: 12, weight: .medium)
        locationLabel.textColor = UIColor.white.withAlphaComponent(0.72)

        conditionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        conditionLabel.textColor = UIColor.white.withAlphaComponent(0.88)

        temperatureLabel.font = .systemFont(ofSize: 36, weight: .thin)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .right

        highLowLabel.font = .systemFont(ofSize: 13, weight: .regular)
        highLowLabel.textColor = UIColor.white.withAlphaComponent(0.82)
        highLowLabel.textAlignment = .right
    }

    private func setupLayout() {
        contentView.addSubview(cardView)
        cardView.addSubview(cityLabel)
        cardView.addSubview(locationLabel)
        cardView.addSubview(conditionLabel)
        cardView.addSubview(temperatureLabel)
        cardView.addSubview(highLowLabel)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 28, bottom: 5, right: 28))
        }

        cityLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(18)
            make.trailing.lessThanOrEqualTo(temperatureLabel.snp.leading).offset(-12)
        }

        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(cityLabel.snp.bottom).offset(2)
            make.leading.equalTo(cityLabel)
            make.trailing.lessThanOrEqualTo(temperatureLabel.snp.leading).offset(-12)
        }

        conditionLabel.snp.makeConstraints { make in
            make.leading.equalTo(cityLabel)
            make.bottom.equalToSuperview().offset(-16)
            make.trailing.lessThanOrEqualTo(highLowLabel.snp.leading).offset(-12)
        }

        temperatureLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-18)
            make.width.greaterThanOrEqualTo(76)
        }

        highLowLabel.snp.makeConstraints { make in
            make.trailing.equalTo(temperatureLabel)
            make.bottom.equalTo(conditionLabel)
            make.leading.greaterThanOrEqualTo(conditionLabel.snp.trailing).offset(12)
        }
    }
}
