protocol GetWeatherUseCaseProtocol {
    func execute(lat: Double, lon: Double) async throws -> Weather
}
