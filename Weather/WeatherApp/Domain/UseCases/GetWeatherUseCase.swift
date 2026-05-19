final class GetWeatherUseCase: GetWeatherUseCaseProtocol {
    private let weatherService: WeatherService
    private let repository: WeatherRepositoryProtocol

    init(apiClient: APIClientProtocol) {
        self.weatherService = WeatherService(api: apiClient)
        self.repository = WeatherRepository(apiClient: apiClient)
    }

    func execute(lat: Double, lon: Double) async throws -> Weather {
        do {
            let response = try await weatherService.oneCall(lat: lat, lon: lon)
            return Weather(from: response)
        } catch {
            return try await repository.fetchWeather(lat: lat, lon: lon)
        }
    }
}
