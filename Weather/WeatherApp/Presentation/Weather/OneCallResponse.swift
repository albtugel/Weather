import Foundation

struct OneCallResponse: Decodable {
    let lat: Double
    let lon: Double
    let timezone: String
    let timezoneOffset: Int
    let current: Current
    let hourly: [Hourly]
    let daily: [Daily]

    enum CodingKeys: String, CodingKey {
        case lat, lon, timezone, current, hourly, daily
        case timezoneOffset = "timezone_offset"
    }

    struct Current: Decodable {
        let dt: TimeInterval
        let sunrise: TimeInterval?
        let sunset: TimeInterval?
        let temp: Double
        let feelsLike: Double?
        let pressure: Int?
        let humidity: Int?
        let windSpeed: Double?
        let windDeg: Int?
        let windGust: Double?
        let visibility: Int?
        let uvIndex: Double?
        let cloudiness: Int?
        let weather: [Condition]

        enum CodingKeys: String, CodingKey {
            case dt, sunrise, sunset, temp, pressure, humidity, visibility, weather
            case feelsLike = "feels_like"
            case windSpeed = "wind_speed"
            case windDeg = "wind_deg"
            case windGust = "wind_gust"
            case uvIndex = "uvi"
            case cloudiness = "clouds"
        }
    }

    struct Hourly: Decodable {
        let dt: TimeInterval
        let temp: Double
        let weather: [Condition]
    }

    struct Daily: Decodable {
        let dt: TimeInterval
        let temp: Temp
        let weather: [Condition]

        struct Temp: Decodable {
            let min: Double
            let max: Double
        }
    }

    struct Condition: Decodable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
}
