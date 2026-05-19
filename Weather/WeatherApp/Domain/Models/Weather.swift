import Foundation

struct Weather {
    let cityName: String
    let temperature: Double
    let tempMin: Double
    let tempMax: Double
    let description: String
    let conditionCode: Int
    let feelsLike: Double?
    let humidity: Int?
    let pressure: Int?
    let windSpeed: Double?
    let windDeg: Int?
    let windGust: Double?
    let sunrise: Date?
    let sunset: Date?
    let visibility: Int?
    let uvIndex: Double?
    let cloudiness: Int?
    let timezoneOffset: Int?
    let hourly: [Hourly]
    let daily: [Daily]

    struct Hourly {
        let date: Date
        let temperature: Double
        let conditionCode: Int
    }

    struct Daily {
        let date: Date
        let tempMin: Double
        let tempMax: Double
        let conditionCode: Int
    }
}

extension Weather {
    static var mock: Weather {
        let now = Date()
        let calendar = Calendar.current
        let timezoneOffset = TimeZone.current.secondsFromGMT()

        let hourly = (0..<16).map { hour in
            let date = calendar.date(byAdding: .hour, value: hour, to: now) ?? now
            return Hourly(
                date: date,
                temperature: Double(11 - hour / 3),
                conditionCode: hour >= 18 ? 800 : 801
            )
        }

        let dailyTemplates = [
            (5.0, 11.0, 801),
            (2.0, 9.0, 500),
            (0.0, 9.0, 804),
            (-2.0, 9.0, 804),
            (-4.0, -1.0, 804),
            (-4.0, 0.0, 804),
            (-4.0, 0.0, 500),
            (-4.0, 1.0, 804),
            (-3.0, 2.0, 804),
            (-2.0, 2.0, 800)
        ]

        let daily = dailyTemplates.enumerated().map { index, item in
            Daily(
                date: calendar.date(byAdding: .day, value: index, to: now) ?? now,
                tempMin: item.0,
                tempMax: item.1,
                conditionCode: item.2
            )
        }

        return Weather(
            cityName: "Алматы",
            temperature: 11,
            tempMin: 5,
            tempMax: 11,
            description: "В основном солнечно",
            conditionCode: 801,
            feelsLike: 10,
            humidity: 62,
            pressure: 1018,
            windSpeed: 3.8,
            windDeg: 210,
            windGust: 6.1,
            sunrise: date(hour: 6, minute: 8, from: now),
            sunset: date(hour: 19, minute: 16, from: now),
            visibility: 10000,
            uvIndex: 4.2,
            cloudiness: 28,
            timezoneOffset: timezoneOffset,
            hourly: hourly,
            daily: daily
        )
    }

    init(from response: OneCallResponse) {
        let current = response.current
        let today = response.daily.first?.temp
        let currentCondition = current.weather.first?.id ?? 800

        self.init(
            cityName: response.timezone,
            temperature: current.temp,
            tempMin: today?.min ?? current.temp,
            tempMax: today?.max ?? current.temp,
            description: current.weather.first?.description ?? "",
            conditionCode: currentCondition,
            feelsLike: current.feelsLike,
            humidity: current.humidity,
            pressure: current.pressure,
            windSpeed: current.windSpeed,
            windDeg: current.windDeg,
            windGust: current.windGust,
            sunrise: current.sunrise.map(Date.init(timeIntervalSince1970:)),
            sunset: current.sunset.map(Date.init(timeIntervalSince1970:)),
            visibility: current.visibility,
            uvIndex: current.uvIndex,
            cloudiness: current.cloudiness,
            timezoneOffset: response.timezoneOffset,
            hourly: response.hourly.map {
                Hourly(
                    date: Date(timeIntervalSince1970: $0.dt),
                    temperature: $0.temp,
                    conditionCode: $0.weather.first?.id ?? currentCondition
                )
            },
            daily: response.daily.map {
                Daily(
                    date: Date(timeIntervalSince1970: $0.dt),
                    tempMin: $0.temp.min,
                    tempMax: $0.temp.max,
                    conditionCode: $0.weather.first?.id ?? currentCondition
                )
            }
        )
    }

    private static func date(hour: Int, minute: Int, from date: Date) -> Date? {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)
    }
}
