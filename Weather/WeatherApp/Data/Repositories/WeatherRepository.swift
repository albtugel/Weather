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
            humidity: dto.main.humidity,
            windSpeed: dto.wind.speed,
            icon: dto.weather.first?.icon ?? ""
        )
    }
}

struct WeatherResponseDTO: Decodable {
    let name: String
    let main: Main
    let weather: [WeatherElement]
    let wind: Wind

    struct Main: Decodable {
        let temp: Double
        let humidity: Int
        let tempMin: Double
        let tempMax: Double

        enum CodingKeys: String, CodingKey {
            case temp
            case humidity
            case tempMin = "temp_min"
            case tempMax = "temp_max"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            temp = try container.decode(Double.self, forKey: .temp)
            humidity = try container.decode(Int.self, forKey: .humidity)
            tempMin = try container.decodeIfPresent(Double.self, forKey: .tempMin) ?? temp
            tempMax = try container.decodeIfPresent(Double.self, forKey: .tempMax) ?? temp
        }
    }

    struct WeatherElement: Decodable {
        let description: String
        let icon: String
    }

    struct Wind: Decodable {
        let speed: Double
    }
}
