import Foundation

final class WeatherRepository: WeatherRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchWeather(lat: Double, lon: Double) async throws -> Weather {
        let dto: WeatherResponseDTO = try await apiClient.request(Endpoint.weather(lat: lat, lon: lon))
        return Weather(
            cityName: dto.name,
            temperature: dto.main.temp,
            tempMin: dto.main.tempMin,
            tempMax: dto.main.tempMax,
            description: dto.weather.first?.description ?? "",
            conditionCode: dto.weather.first?.id ?? 800,
            windSpeed: dto.wind?.speed,
            windDeg: dto.wind?.deg,
            timezoneOffset: nil,
            hourly: [],
            daily: []
        )
    }
}

struct WeatherResponseDTO: Decodable {
    let name: String
    let main: Main
    let weather: [WeatherElement]
    let wind: Wind?

    struct Main: Decodable {
        let temp: Double
        let tempMin: Double
        let tempMax: Double

        enum CodingKeys: String, CodingKey {
            case temp
            case tempMin = "temp_min"
            case tempMax = "temp_max"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            temp = try container.decode(Double.self, forKey: .temp)
            tempMin = try container.decodeIfPresent(Double.self, forKey: .tempMin) ?? temp
            tempMax = try container.decodeIfPresent(Double.self, forKey: .tempMax) ?? temp
        }
    }

    struct WeatherElement: Decodable {
        let id: Int?
        let description: String
    }

    struct Wind: Decodable {
        let speed: Double?
        let deg: Int?
    }
}
