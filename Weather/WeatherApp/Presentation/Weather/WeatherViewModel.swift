import Combine
import CoreLocation
import Foundation

final class WeatherViewModel {

    private(set) var screenState: CurrentValueSubject<WeatherScreenState, Never>

    private let locationManager: LocationManagerProtocol
    private let getWeatherUseCase: GetWeatherUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    private var lastLocation: CLLocation?
    private var latestWeather: Weather?
    private var latestViewState: WeatherViewState?
    private var locationText = "ТЕКУЩЕЕ МЕСТО"
    private var cityName: String?
    private var followsCurrentLocation = true
    private var isFetching = false

    init(
        locationManager: LocationManagerProtocol = DIContainer.shared.locationManager,
        getWeatherUseCase: GetWeatherUseCaseProtocol = DIContainer.shared.getWeatherUseCase
    ) {
        self.locationManager = locationManager
        self.getWeatherUseCase = getWeatherUseCase

        self.screenState = CurrentValueSubject<WeatherScreenState, Never>(.loading)

        subscribeToLocationUpdates()
    }

    func viewDidLoad() {
        cityName = nil
        setLoadingIfNeeded()
        locationManager.requestLocation()
    }

    func refreshForCurrentUnit() {
        let state = makeState(weather: latestWeather)
        latestViewState = state
        screenState.send(.content(state))
    }

    func loadCity(_ city: City) {
        followsCurrentLocation = city.isCurrent
        locationText = city.isCurrent ? "ТЕКУЩЕЕ МЕСТО" : "СОХРАНЕННЫЙ ГОРОД"
        cityName = city.isCurrent ? nil : city.name
        lastLocation = CLLocation(latitude: city.lat, longitude: city.lon)
        startFetching(lat: city.lat, lon: city.lon, forceRefresh: true)
    }

    func refresh() {
        guard !isFetching else { return }

        if let lastLocation {
            startFetching(
                lat: lastLocation.coordinate.latitude,
                lon: lastLocation.coordinate.longitude,
                forceRefresh: true
            )
            return
        }

        setLoadingIfNeeded()
        locationManager.requestLocation()
    }

    private func subscribeToLocationUpdates() {
        locationManager.statusPublisher
            .sink { [weak self] status in
                self?.handleLocationStatus(status)
            }
            .store(in: &cancellables)
    }

    private func handleLocationStatus(_ status: LocationStatus) {
        switch status {
        case .notDetermined:
            setLoadingIfNeeded()
        case .denied:
            isFetching = false
        case .failed:
            isFetching = false
        case let .authorized(location):
            guard followsCurrentLocation else { return }
            guard shouldFetchWeather(for: location) else { return }
            lastLocation = location
            locationText = "ТЕКУЩЕЕ МЕСТО"
            cityName = nil
            startFetching(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude,
                forceRefresh: false
            )
        }
    }

    private func shouldFetchWeather(for location: CLLocation) -> Bool {
        guard let lastLocation else { return true }
        return location.distance(from: lastLocation) >= 50
    }

    private func startFetching(lat: Double, lon: Double, forceRefresh: Bool) {
        guard !isFetching else { return }
        isFetching = true

        if forceRefresh, let latestViewState {
            screenState.send(.refreshing(latestViewState))
        } else {
            setLoadingIfNeeded()
        }

        Task { [weak self] in
            await self?.fetchWeather(lat: lat, lon: lon)
        }
    }

    private func fetchWeather(lat: Double, lon: Double) async {
        do {
            let weather = try await getWeatherUseCase.execute(lat: lat, lon: lon)
            publish(weather: weather)
        } catch {
            await MainActor.run {
                self.isFetching = false
                let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                self.screenState.send(.error(message))
            }
        }
    }

    @MainActor
    private func publish(weather: Weather) {
        isFetching = false
        latestWeather = weather
        let state = makeState(weather: weather)
        latestViewState = state
        screenState.send(.content(state))
    }

    private func makeState(weather: Weather?) -> WeatherViewState {
        let current = makeCurrentWeather(from: weather)
        let headerState = makeHeaderState(weather: weather, current: current)

        return WeatherViewState(
            backgroundConditionCode: current.conditionCode,
            locationText: locationText,
            cityName: headerState.cityName,
            temperatureText: headerState.temperatureText,
            conditionText: headerState.conditionText,
            highLowText: headerState.highLowText,
            compactSummaryText: headerState.compactSummaryText,
            forecastSummary: current.forecastSummary,
            hourlyItems: hourlyItems(from: weather),
            dailyItems: dailyItems(from: weather),
            detailItems: detailItems(from: weather)
        )
    }

    private func makeHeaderState(weather: Weather?, current: MockWeatherData.Current) -> HeaderState {
        let unit = AppSettings.shared.temperatureUnit
        let cityName = cityName ?? weather?.cityName ?? current.cityName
        let conditionText = weather?.description ?? current.description
        let temperatureText = formattedTemperature(weather?.temperature, fallback: current.temperature, unit: unit)
        let high = formattedTemperature(weather?.tempMax, fallback: current.high, unit: unit)
        let low = formattedTemperature(weather?.tempMin, fallback: current.low, unit: unit)

        return HeaderState(
            cityName: cityName,
            temperatureText: temperatureText,
            conditionText: conditionText,
            highLowText: "Макс.: \(high), мин.: \(low)",
            compactSummaryText: "\(cityName)  \(temperatureText) | \(conditionText)"
        )
    }

    private func formattedTemperature(_ value: Double?, fallback: Int, unit: TemperatureUnit) -> String {
        if let value {
            return value.formatted(unit: unit)
        }

        return Double(fallback).formatted(unit: unit)
    }

    private func makeCurrentWeather(from weather: Weather?) -> MockWeatherData.Current {
        guard let weather = weather else { return MockWeatherData.current }
        return MockWeatherData.Current(
            cityName: weather.cityName,
            locationType: locationText,
            temperature: Int(weather.temperature.rounded()),
            description: weather.description,
            high: Int(weather.tempMax.rounded()),
            low: Int(weather.tempMin.rounded()),
            conditionCode: weather.conditionCode,
            forecastSummary: MockWeatherData.current.forecastSummary
        )
    }

    private func hourlyItems(from weather: Weather?) -> [MockWeatherData.HourlyWeather] {
        guard let weather else { return MockWeatherData.hourly }
        return MockWeatherData.hourly(from: weather.hourly, timezoneOffset: weather.timezoneOffset)
    }

    private func dailyItems(from weather: Weather?) -> [MockWeatherData.DailyWeather] {
        guard let weather else { return MockWeatherData.daily }
        return MockWeatherData.daily(from: weather.daily, timezoneOffset: weather.timezoneOffset)
    }

    private func detailItems(from weather: Weather?) -> [WeatherDetailItem] {
        let weather = weather ?? .mock
        let unit = AppSettings.shared.temperatureUnit
        let average = (weather.tempMin + weather.tempMax) / 2
        let high = formattedTemperature(weather.tempMax, fallback: Int(weather.tempMax.rounded()), unit: unit)
        let current = formattedTemperature(weather.temperature, fallback: Int(weather.temperature.rounded()), unit: unit)
        let diff = abs(weather.temperature - average)

        return [
            WeatherDetailItem(
                title: "В среднем",
                value: "На \(diff.formatted(unit: unit))",
                subtitle: weather.temperature >= average
                    ? "> среднесуточного максимума"
                    : "< среднесуточного максимума",
                icon: "chart.line.uptrend.xyaxis",
                note: "Сегодня \(current)\nМакс.: \(high)"
            ),
            WeatherDetailItem(
                title: "Ощущается как",
                value: formattedTemperature(weather.feelsLike, fallback: Int(weather.temperature.rounded()), unit: unit),
                subtitle: feelsLikeSubtitle(weather.feelsLike, temperature: weather.temperature),
                icon: "thermometer.medium"
            ),
            WeatherDetailItem(
                title: "Ветер",
                value: "",
                icon: "wind",
                kind: .wind,
                rows: [
                    WeatherDetailRow(title: "Ветер", value: formattedWind(weather.windSpeed)),
                    WeatherDetailRow(title: "Порывы ветра", value: formattedWind(weather.windGust)),
                    WeatherDetailRow(title: "Направление", value: formattedWindDirection(weather.windDeg))
                ]
            ),
            WeatherDetailItem(
                title: "УФ-индекс",
                value: formattedUVIndex(weather.uvIndex),
                subtitle: uvSubtitle(weather.uvIndex),
                icon: "sun.max.fill",
                kind: .uv,
                note: uvNote(weather.uvIndex)
            ),
            WeatherDetailItem(
                title: "Закат",
                value: formattedTime(weather.sunset, timezoneOffset: weather.timezoneOffset),
                icon: "sunset.fill",
                note: "Восход в \(formattedTime(weather.sunrise, timezoneOffset: weather.timezoneOffset))."
            ),
            WeatherDetailItem(
                title: "Влажность",
                value: formattedPercent(weather.humidity),
                icon: "humidity.fill",
                note: dewPointText(weather)
            ),
            WeatherDetailItem(
                title: "Давление",
                value: formattedPressure(weather.pressure),
                icon: "gauge.medium",
                note: "↓ гПа"
            )
        ]
    }

    private func formattedWind(_ speed: Double?) -> String {
        guard let speed else { return "--" }
        return "\(Int((speed * 3.6).rounded())) км/ч"
    }

    private func windDirection(from degrees: Int) -> String {
        let directions = ["С", "СВ", "В", "ЮВ", "Ю", "ЮЗ", "З", "СЗ"]
        let index = Int((Double(degrees) / 45.0).rounded()) % directions.count
        return directions[index]
    }

    private func formattedWindDirection(_ degrees: Int?) -> String {
        guard let degrees else { return "--" }
        return "\(degrees)° \(windDirection(from: degrees))"
    }

    private func formattedPercent(_ value: Int?) -> String {
        guard let value else { return "--" }
        return "\(value) %"
    }

    private func feelsLikeSubtitle(_ feelsLike: Double?, temperature: Double) -> String? {
        guard let feelsLike else { return nil }
        let diff = abs(feelsLike - temperature)
        if diff < 1 {
            return "Похоже на фактическую."
        }

        return feelsLike > temperature
            ? "По ощущениям теплее, чем на самом деле."
            : "По ощущениям прохладнее, чем на самом деле."
    }

    private func formattedPressure(_ pressure: Int?) -> String {
        guard let pressure else { return "--" }
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: pressure)) ?? "\(pressure)"
    }

    private func formattedTime(_ date: Date?, timezoneOffset: Int?) -> String {
        guard let date else { return "--" }
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = timezoneOffset.flatMap(TimeZone.init(secondsFromGMT:)) ?? .autoupdatingCurrent
        return formatter.string(from: date)
    }

    private func formattedUVIndex(_ uvIndex: Double?) -> String {
        guard let uvIndex else { return "--" }
        return "\(Int(uvIndex.rounded()))"
    }

    private func uvSubtitle(_ uvIndex: Double?) -> String? {
        guard let uvIndex else { return nil }
        switch uvIndex {
        case 0..<3: return "Низкий"
        case 3..<6: return "Средний"
        case 6..<8: return "Высокий"
        default: return "Очень высокий"
        }
    }

    private func uvNote(_ uvIndex: Double?) -> String? {
        guard let level = uvSubtitle(uvIndex)?.lowercased() else { return nil }
        return "Останется \(level) до конца дня."
    }

    private func dewPointText(_ weather: Weather) -> String? {
        guard let humidity = weather.humidity else { return nil }
        let dewPoint = weather.temperature - Double(100 - humidity) / 5
        let value = formattedTemperature(dewPoint, fallback: Int(dewPoint.rounded()), unit: AppSettings.shared.temperatureUnit)
        return "Точка росы сейчас: \(value)."
    }

    private func setLoadingIfNeeded() {
        guard latestViewState == nil, !isFetching else { return }
        screenState.send(.loading)
    }
}

private extension WeatherViewModel {
    struct HeaderState {
        let cityName: String
        let temperatureText: String
        let conditionText: String
        let highLowText: String
        let compactSummaryText: String
    }
}
