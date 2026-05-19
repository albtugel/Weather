import Foundation

struct WeatherViewState {
    let backgroundConditionCode: Int
    let locationText: String
    let cityName: String
    let temperatureText: String
    let conditionText: String
    let highLowText: String
    let compactSummaryText: String
    let forecastSummary: String
    let hourlyItems: [MockWeatherData.HourlyWeather]
    let dailyItems: [MockWeatherData.DailyWeather]
    let detailItems: [WeatherDetailItem]
}

struct WeatherDetailItem {
    enum Kind {
        case normal
        case wind
        case uv
    }

    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let kind: Kind
    let rows: [WeatherDetailRow]
    let note: String?

    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String,
        kind: Kind = .normal,
        rows: [WeatherDetailRow] = [],
        note: String? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.kind = kind
        self.rows = rows
        self.note = note
    }
}

struct WeatherDetailRow {
    let title: String
    let value: String
}
