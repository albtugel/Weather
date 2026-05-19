final class DIContainer {
    static let shared = DIContainer()

    private init() {}

    lazy var apiClient: APIClientProtocol = APIClient()

    lazy var weatherRepository: WeatherRepositoryProtocol =
        WeatherRepository(apiClient: apiClient)

    lazy var locationManager: LocationManagerProtocol =
        LocationManager()

    lazy var getWeatherUseCase: GetWeatherUseCaseProtocol =
        GetWeatherUseCase(apiClient: apiClient)

    lazy var cityStore = CityStore()

    lazy var cityLookup = CityLookup()
}
