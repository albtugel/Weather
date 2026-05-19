final class GetWeatherUseCase: GetWeatherUseCaseProtocol {
    
    private let weatherService = WeatherService.shared
    
    func execute(lat: Double, lon: Double) async throws -> Weather {
        let response = try await weatherService.oneCall(lat: lat, lon: lon)
        return Weather(from: response)
    }
}
