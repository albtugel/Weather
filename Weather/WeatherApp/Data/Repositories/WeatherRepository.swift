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
            feelsLike: dto.main.feelsLike,
            humidity: dto.main.humidity,
            pressure: dto.main.pressure,
            windSpeed: dto.wind?.speed,
            windDeg: dto.wind?.deg,
            windGust: dto.wind?.gust,
            sunrise: dto.sys?.sunrise.map(Date.init(timeIntervalSince1970:)),
            sunset: dto.sys?.sunset.map(Date.init(timeIntervalSince1970:)),
            visibility: dto.visibility,
            uvIndex: nil,
            cloudiness: dto.clouds?.all,
            timezoneOffset: dto.timezone,
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
    let sys: Sys?
    let visibility: Int?
    let clouds: Clouds?
    let timezone: Int?

    struct Main: Decodable {
        let temp: Double
        let tempMin: Double
        let tempMax: Double
        let feelsLike: Double?
        let pressure: Int?
        let humidity: Int?

        enum CodingKeys: String, CodingKey {
            case temp, pressure, humidity
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case feelsLike = "feels_like"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            temp = try container.decode(Double.self, forKey: .temp)
            tempMin = try container.decodeIfPresent(Double.self, forKey: .tempMin) ?? temp
            tempMax = try container.decodeIfPresent(Double.self, forKey: .tempMax) ?? temp
            feelsLike = try container.decodeIfPresent(Double.self, forKey: .feelsLike)
            pressure = try container.decodeIfPresent(Int.self, forKey: .pressure)
            humidity = try container.decodeIfPresent(Int.self, forKey: .humidity)
        }
    }

    struct WeatherElement: Decodable {
        let id: Int?
        let description: String
    }

    struct Wind: Decodable {
        let speed: Double?
        let deg: Int?
        let gust: Double?
    }

    struct Sys: Decodable {
        let sunrise: TimeInterval?
        let sunset: TimeInterval?
    }

    struct Clouds: Decodable {
        let all: Int?
    }
}
