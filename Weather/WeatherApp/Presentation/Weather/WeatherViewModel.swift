import Combine
import CoreLocation
import Foundation

final class WeatherViewModel {

    private(set) var viewState: CurrentValueSubject<WeatherViewState, Never>

    private let locationManager: LocationManagerProtocol
    private let getWeatherUseCase: GetWeatherUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    private var lastLocation: CLLocation?
    private var latestWeather: Weather?

    init(
        locationManager: LocationManagerProtocol = DIContainer.shared.locationManager,
        getWeatherUseCase: GetWeatherUseCaseProtocol = DIContainer.shared.getWeatherUseCase
    ) {
        self.locationManager = locationManager
        self.getWeatherUseCase = getWeatherUseCase
        
        let initialState = Self.makeInitialState()
        self.viewState = CurrentValueSubject<WeatherViewState, Never>(initialState)
        
        subscribeToLocationUpdates()
    }

    func viewDidLoad() {
        locationManager.requestLocation()
    }

    func refreshForCurrentUnit() {
        viewState.send(Self.makeState(weather: latestWeather))
    }

    private func subscribeToLocationUpdates() {
        locationManager.statusPublisher
            .sink { [weak self] status in
                self?.handleLocationStatus(status)
            }
            .store(in: &cancellables)
    }

    private func handleLocationStatus(_ status: LocationStatus) {
        guard case let .authorized(location) = status else { return }
        guard shouldFetchWeather(for: location) else { return }

        lastLocation = location

        Task { [weak self] in
            await self?.fetchWeather(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude
            )
        }
    }

    private func shouldFetchWeather(for location: CLLocation) -> Bool {
        guard let lastLocation else { return true }
        return location.distance(from: lastLocation) >= 50
    }

    private func fetchWeather(lat: Double, lon: Double) async {
        do {
            let weather = try await getWeatherUseCase.execute(lat: lat, lon: lon)

            publish(weather: weather)
        } catch {
            print("Weather fetch error: \(error)")
        }
    }

    @MainActor
    private func publish(weather: Weather) {
        latestWeather = weather
        viewState.send(Self.makeState(weather: weather))
    }

    private static func makeInitialState() -> WeatherViewState {
        makeState(weather: nil)
    }

    private static func makeState(weather: Weather?) -> WeatherViewState {
        let current = makeCurrentWeather(from: weather)
        let headerState = makeHeaderState(weather: weather, current: current)

        return WeatherViewState(
            backgroundConditionCode: current.conditionCode,
            locationText: current.locationType,
            cityName: headerState.cityName,
            temperatureText: headerState.temperatureText,
            conditionText: headerState.conditionText,
            highLowText: headerState.highLowText,
            compactSummaryText: headerState.compactSummaryText,
            currentWeather: current,
            hourlyItems: MockWeatherData.hourly,
            dailyItems: MockWeatherData.daily
        )
    }

    private static func makeHeaderState(weather: Weather?, current: MockWeatherData.Current) -> HeaderState {
        let unit = AppSettings.shared.temperatureUnit
        let cityName = weather?.cityName ?? current.cityName
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

    private static func formattedTemperature(_ value: Double?, fallback: Int, unit: TemperatureUnit) -> String {
        if let value {
            return value.formatted(unit: unit)
        }

        return Double(fallback).formatted(unit: unit)
    }

    private static func makeCurrentWeather(from weather: Weather?) -> MockWeatherData.Current {
        guard let weather = weather else { return MockWeatherData.current }
        return MockWeatherData.Current(
            cityName: weather.cityName,
            locationType: "ТЕКУЩЕЕ МЕСТО",
            temperature: Int(weather.temperature.rounded()),
            description: weather.description,
            high: Int(weather.tempMax.rounded()),
            low: Int(weather.tempMin.rounded()),
            humidity: weather.humidity,
            windSpeed: Int(weather.windSpeed.rounded()),
            windGust: MockWeatherData.current.windGust,
            windDirection: MockWeatherData.current.windDirection,
            feelsLike: Int(weather.temperature.rounded()),
            uvIndex: MockWeatherData.current.uvIndex,
            uvDescription: MockWeatherData.current.uvDescription,
            uvForecast: MockWeatherData.current.uvForecast,
            visibility: MockWeatherData.current.visibility,
            pressure: MockWeatherData.current.pressure,
            pressureTrend: MockWeatherData.current.pressureTrend,
            sunrise: MockWeatherData.current.sunrise,
            sunset: MockWeatherData.current.sunset,
            conditionCode: MockWeatherData.current.conditionCode,
            forecastSummary: MockWeatherData.current.forecastSummary,
            averageTemp: MockWeatherData.current.averageTemp,
            averageTempDelta: MockWeatherData.current.averageTempDelta
        )
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
