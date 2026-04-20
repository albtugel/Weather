import Combine
import CoreLocation
import Foundation

final class WeatherViewModel {
    @Published private(set) var logOutput: String = "Ожидание местоположения..."
    @Published private(set) var weather: Weather?

    private let locationManager: LocationManagerProtocol
    private let getWeatherUseCase: GetWeatherUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    private var lastLocation: CLLocation?

    init(
        locationManager: LocationManagerProtocol = DIContainer.shared.locationManager,
        getWeatherUseCase: GetWeatherUseCaseProtocol = DIContainer.shared.getWeatherUseCase
    ) {
        self.locationManager = locationManager
        self.getWeatherUseCase = getWeatherUseCase
        subscribeToLocationUpdates()
    }

    func viewDidLoad() {
        locationManager.requestLocation()
    }

    private func subscribeToLocationUpdates() {
        locationManager.statusPublisher
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .notDetermined:
                    break
                case .denied:
                    Task { await self.updateLogOutput("Доступ к геолокации запрещен") }
                case .failed(_):
                    Task { await self.updateLogOutput("Не удалось получить местоположение") }
                case .authorized(let location):
                    if let lastLocation, location.distance(from: lastLocation) < 50 {
                        return
                    }
                    lastLocation = location
                    let lat = location.coordinate.latitude
                    let lon = location.coordinate.longitude
                    Task { await self.updateLogOutput("Координаты: \(lat), \(lon)") }
                    Task { await self.fetchWeather(lat: lat, lon: lon) }
                }
            }
            .store(in: &cancellables)
    }

    private func fetchWeather(lat: Double, lon: Double) async {
        do {
            let weather = try await getWeatherUseCase.execute(lat: lat, lon: lon)
            let text = "Город: \(weather.cityName)\nТемпература: \(weather.temperature)\nОписание: \(weather.description)"
            await updateLogOutput(text)
            await MainActor.run {
                self.weather = weather
            }
        } catch let error as NetworkError {
            await updateLogOutput(error.localizedDescription)
        } catch {
            await updateLogOutput("Неизвестная ошибка")
        }
    }

    private func updateLogOutput(_ text: String) async {
        print(text)
        await MainActor.run {
            self.logOutput = text
        }
    }
}
