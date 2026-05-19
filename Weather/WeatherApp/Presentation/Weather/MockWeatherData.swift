import Foundation

struct MockWeatherData {
    struct Current {
        let cityName: String
        let locationType: String
        let temperature: Int
        let description: String
        let high: Int
        let low: Int
        let conditionCode: Int
        let forecastSummary: String
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

    static let current = Current(
        cityName: "Алматы",
        locationType: "ТЕКУЩЕЕ МЕСТО",
        temperature: 11,
        description: "В основном солнечно",
        high: 11,
        low: 5,
        conditionCode: 801,
        forecastSummary: "Солнечно до конца дня."
    )

    static let hourly: [HourlyWeather] = makeHourly()
    static let daily: [DailyWeather] = makeDaily()

    private static func currentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    private static func makeHourly() -> [HourlyWeather] {
        let now = Date()
        let calendar = Calendar.current

        var items: [HourlyWeather] = [
            HourlyWeather(label: "Сейчас", temp: 11, icon: "sun.max.fill", isSunset: false)
        ]

        for hour in 1...15 {
            let date = calendar.date(byAdding: .hour, value: hour, to: now) ?? now
            let hourString = String(calendar.component(.hour, from: date))
            items.append(
                HourlyWeather(
                    label: hourString,
                    temp: 10 - hour/3,
                    icon: hour >= 18 ? "moon.fill" : "sun.max.fill",
                    isSunset: false
                )
            )
        }

        items.insert(
            HourlyWeather(label: "17:29", temp: nil, icon: "sunset.fill", isSunset: true),
            at: 3
        )

        return items
    }

    private static func makeDaily() -> [DailyWeather] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("EEE")

        let startDate = calendar.startOfDay(for: Date())
        let templates = [
            ("sun.max.fill", 5, 11),
            ("cloud.rain.fill", 2, 9),
            ("cloud.fill", 0, 9),
            ("cloud.fill", -2, 9),
            ("cloud.fill", -4, -1),
            ("cloud.fill", -4, 0),
            ("cloud.rain.fill", -4, 0),
            ("cloud.fill", -4, 1),
            ("cloud.fill", -3, 2),
            ("sun.max.fill", -2, 2)
        ]

        return templates.enumerated().map { index, item in
            let day = index == 0
                ? NSLocalizedString("Сегодня", comment: "")
                : formatter.string(from: calendar.date(byAdding: .day, value: index, to: startDate)!).capitalized
            return DailyWeather(day: day, icon: item.0, low: item.1, high: item.2)
        }
    }
}
