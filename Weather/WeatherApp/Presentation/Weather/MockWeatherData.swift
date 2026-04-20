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
        conditionCode: 801,
        forecastSummary: "Солнечно до конца дня."
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

    static let daily: [DailyWeather] = makeDailyForecast()

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

    private static func makeDailyForecast() -> [DailyWeather] {
        let templates: [(icon: String, low: Int, high: Int)] = [
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

        let calendar = Calendar.current
        let weekdaySymbols = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]
        let startDate = calendar.startOfDay(for: Date())

        return templates.enumerated().map { index, template in
            let dayTitle: String

            if index == 0 {
                dayTitle = "Сегодня"
            } else {
                let date = calendar.date(byAdding: .day, value: index, to: startDate) ?? startDate
                let weekdayIndex = calendar.component(.weekday, from: date) - 1
                dayTitle = weekdaySymbols[weekdayIndex]
            }

            return DailyWeather(
                day: dayTitle,
                icon: template.icon,
                low: template.low,
                high: template.high
            )
        }
    }
}
