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

    static func hourly(from forecasts: [Weather.Hourly], timezoneOffset: Int?) -> [HourlyWeather] {
        guard !forecasts.isEmpty else { return hourly }

        let formatter = hourFormatter(timezoneOffset: timezoneOffset)
        return forecasts.prefix(16).enumerated().map { index, forecast in
            HourlyWeather(
                label: index == 0 ? "Сейчас" : formatter.string(from: forecast.date),
                temp: Int(forecast.temperature.rounded()),
                icon: iconName(for: forecast.conditionCode, date: forecast.date, timezoneOffset: timezoneOffset),
                isSunset: false
            )
        }
    }

    static func daily(from forecasts: [Weather.Daily], timezoneOffset: Int?) -> [DailyWeather] {
        guard !forecasts.isEmpty else { return daily }

        let formatter = dayFormatter(timezoneOffset: timezoneOffset)
        return forecasts.prefix(10).enumerated().map { index, forecast in
            DailyWeather(
                day: index == 0 ? NSLocalizedString("Сегодня", comment: "") : formatter.string(from: forecast.date).capitalized,
                icon: iconName(for: forecast.conditionCode, date: forecast.date, timezoneOffset: timezoneOffset),
                low: Int(forecast.tempMin.rounded()),
                high: Int(forecast.tempMax.rounded())
            )
        }
    }

    private static func makeHourly() -> [HourlyWeather] {
        let now = Date()
        let calendar = Calendar.current
        let formatter = hourFormatter(timezoneOffset: nil)

        var items: [HourlyWeather] = [
            HourlyWeather(label: "Сейчас", temp: 11, icon: "sun.max.fill", isSunset: false)
        ]

        for hour in 1...15 {
            let date = calendar.date(byAdding: .hour, value: hour, to: now) ?? now
            items.append(
                HourlyWeather(
                    label: formatter.string(from: date),
                    temp: 10 - hour/3,
                    icon: iconName(for: hour >= 18 ? 800 : 801, date: date, timezoneOffset: nil),
                    isSunset: false
                )
            )
        }

        if items.count > 3 {
            items.insert(
                HourlyWeather(label: sunsetLabel(for: now), temp: nil, icon: "sunset.fill", isSunset: true),
                at: 3
            )
        }

        return items
    }

    private static func makeDaily() -> [DailyWeather] {
        let calendar = Calendar.current
        let formatter = dayFormatter(timezoneOffset: nil)

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

    private static func hourFormatter(timezoneOffset: Int?) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "HH"
        formatter.timeZone = timeZone(from: timezoneOffset)
        return formatter
    }

    private static func dayFormatter(timezoneOffset: Int?) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.timeZone = timeZone(from: timezoneOffset)
        formatter.setLocalizedDateFormatFromTemplate("EEE")
        return formatter
    }

    private static func sunsetLabel(for date: Date) -> String {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 17
        components.minute = 29

        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Calendar.current.date(from: components) ?? date)
    }

    private static func timeZone(from offset: Int?) -> TimeZone {
        offset.flatMap(TimeZone.init(secondsFromGMT:)) ?? .autoupdatingCurrent
    }

    private static func iconName(for conditionCode: Int, date: Date, timezoneOffset: Int?) -> String {
        switch conditionCode {
        case 200...599:
            return "cloud.rain.fill"
        case 600...699:
            return "snowflake"
        case 700...799:
            return "cloud.fog.fill"
        case 800:
            var calendar = Calendar.current
            calendar.timeZone = timeZone(from: timezoneOffset)
            let hour = calendar.component(.hour, from: date)
            return (6...18).contains(hour) ? "sun.max.fill" : "moon.fill"
        case 801...899:
            return "cloud.sun.fill"
        default:
            return "cloud.fill"
        }
    }
}
