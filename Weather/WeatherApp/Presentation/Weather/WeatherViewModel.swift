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

    private func subscribeToLocationUpdates() {
        locationManager.statusPublisher
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .authorized(let location):
                    if let lastLocation = self.lastLocation, location.distance(from: lastLocation) < 50 {
                        return
                    }
                    self.lastLocation = location
                    let lat = location.coordinate.latitude
                    let lon = location.coordinate.longitude
                    
                    Task { [weak self] in
                        await self?.fetchWeather(lat: lat, lon: lon)
                    }
                case .denied, .failed, .notDetermined:
                    break
                }
            }
            .store(in: &cancellables)
    }

    func refreshForCurrentUnit() {
        let newState = Self.makeState(weather: latestWeather)

        viewState.send(newState)
    }

    private func fetchWeather(lat: Double, lon: Double) async {
        do {
            let weather = try await getWeatherUseCase.execute(lat: lat, lon: lon)
            
            await MainActor.run {
                self.latestWeather = weather
                let newState = Self.makeState(weather: weather)
                self.viewState.send(newState)
            }
        } catch {
            print("Weather fetch error: \(error)")
        }
    }

    private static func makeInitialState() -> WeatherViewState {
        makeState(weather: nil)
    }

    private static func makeState(weather: Weather?) -> WeatherViewState {
        let current = makeCurrentWeather(from: weather)
        let unit = AppSettings.shared.temperatureUnit
        let temperatureText = weather?.temperature.formatted(unit: unit) ?? Double(current.temperature).formatted(unit: unit)
        let high = weather?.tempMax.formatted(unit: unit) ?? Double(current.high).formatted(unit: unit)
        let low = weather?.tempMin.formatted(unit: unit) ?? Double(current.low).formatted(unit: unit)
        let cityName = weather?.cityName ?? current.cityName
        let conditionText = weather?.description ?? current.description
        let compactSummaryText = "\(cityName)  \(temperatureText) | \(conditionText)"

        return WeatherViewState(
            backgroundConditionCode: current.conditionCode,
            locationText: current.locationType,
            cityName: cityName,
            temperatureText: temperatureText,
            conditionText: conditionText,
            highLowText: "Макс.: \(high), мин.: \(low)",
            compactSummaryText: compactSummaryText,
            currentWeather: current,
            hourlyItems: MockWeatherData.hourly,
            dailyItems: MockWeatherData.daily
        )
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
