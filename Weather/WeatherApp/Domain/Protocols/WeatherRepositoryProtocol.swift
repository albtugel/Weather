protocol WeatherRepositoryProtocol {
    func fetchWeather(lat: Double, lon: Double) async throws -> Weather
}
