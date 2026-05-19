final class GetWeatherUseCase: GetWeatherUseCaseProtocol {
    private let weatherService: WeatherService

    init(apiClient: APIClientProtocol) {
        self.weatherService = WeatherService(api: apiClient)
    }

    func execute(lat: Double, lon: Double) async throws -> Weather {
        do {
            let response = try await weatherService.oneCall(lat: lat, lon: lon)
            return Weather(from: response)
        } catch {
            return .mock
        }
    }
}
