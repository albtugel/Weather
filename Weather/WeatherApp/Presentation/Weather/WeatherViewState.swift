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
}
