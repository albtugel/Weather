import Foundation

struct MockWeatherData {
    struct Current {
        let cityName: String
        let locationType: String
        let temperature: Int
        let description: String
        let high: Int
        let low: Int
        let humidity: Int
        let windSpeed: Int
        let windGust: Int
        let windDirection: String
        let feelsLike: Int
        let uvIndex: Int
        let uvDescription: String
        let uvForecast: String
        let visibility: Int
        let pressure: Int
        let pressureTrend: String
        let sunrise: Date
        let sunset: Date
        let conditionCode: Int
        let forecastSummary: String
        let averageTemp: Int
        let averageTempDelta: String
    }

    struct HourlyWeather {
        let label: String
        let temp: Int?
        let icon: String
        let isSunset: Bool
    }

    struct DailyWeather {
        let day: String
        let icon: String
        let low: Int
        let high: Int
    }

    struct CityWeather {
        let name: String
        let type: String?
        let time: String?
        let condition: String
        let high: Int
        let low: Int
        let temp: Int
    }

    static let current = Current(
        cityName: "Алматы",
        locationType: "ТЕКУЩЕЕ МЕСТО",
        temperature: 11,
        description: "В основном солнечно",
        high: 11,
        low: 5,
        humidity: 70,
        windSpeed: 6,
        windGust: 14,
        windDirection: "СВ 38°",
        feelsLike: 12,
        uvIndex: 0,
        uvDescription: "Низкий",
        uvForecast: "Останется низким до конца дня.",
        visibility: 24,
        pressure: 1022,
        pressureTrend: "falling",
        sunrise: today(hour: 6, minute: 41),
        sunset: today(hour: 17, minute: 29),
        conditionCode: 801,
        forecastSummary: "Порывы ветра до 14 км/ч. Солнечно до конца дня.",
        averageTemp: 10,
        averageTempDelta: "+10° выше среднесуточного максимума"
    )

    static let hourly: [HourlyWeather] = {
        var items: [HourlyWeather] = [
            .init(label: "Сейчас", temp: 11, icon: "sun.max.fill", isSunset: false),
            .init(label: "16", temp: 10, icon: "sun.max.fill", isSunset: false),
            .init(label: "17", temp: 9, icon: "sun.max.fill", isSunset: false),
            .init(label: "17:29", temp: nil, icon: "sunset.fill", isSunset: true),
            .init(label: "18", temp: 8, icon: "moon.fill", isSunset: false),
            .init(label: "19", temp: 7, icon: "moon.fill", isSunset: false)
        ]

        let additionalLabels = [
            "20", "21", "22", "23",
            "00", "01", "02", "03", "04", "05",
            "06", "07", "08", "09", "10", "11", "12", "13"
        ]
        for label in additionalLabels {
            items.append(.init(label: label, temp: 7, icon: "moon.fill", isSunset: false))
        }

        return items
    }()

    static let daily: [DailyWeather] = [
        .init(day: "Сегодня", icon: "sun.max.fill", low: 5, high: 11),
        .init(day: "Сб", icon: "cloud.rain.fill", low: 2, high: 9),
        .init(day: "Вс", icon: "cloud.fill", low: 0, high: 9),
        .init(day: "Пн", icon: "cloud.fill", low: -2, high: 9),
        .init(day: "Вт", icon: "cloud.fill", low: -4, high: -1),
        .init(day: "Ср", icon: "cloud.fill", low: -4, high: 0),
        .init(day: "Чт", icon: "cloud.rain.fill", low: -4, high: 0),
        .init(day: "Пт", icon: "cloud.fill", low: -4, high: 1),
        .init(day: "Сб", icon: "cloud.fill", low: -3, high: 2),
        .init(day: "Вс", icon: "sun.max.fill", low: -2, high: 2)
    ]

    static let cities: [CityWeather] = [
        .init(
            name: "Алматы",
            type: "Текущее место",
            time: nil,
            condition: "В основном солнечно",
            high: 11,
            low: 5,
            temp: 11
        ),
        .init(
            name: "Астана",
            type: nil,
            time: "15:58",
            condition: "В основном облачно",
            high: -10,
            low: -22,
            temp: -10
        ),
        .init(
            name: "Алматы",
            type: nil,
            time: "15:58",
            condition: "В основном солнечно",
            high: 22,
            low: 8,
            temp: 22
        )
    ]

    private static func today(hour: Int, minute: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
}
