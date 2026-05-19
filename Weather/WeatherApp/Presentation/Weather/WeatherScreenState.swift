enum WeatherScreenState {
    case loading
    case content(WeatherViewState)
    case refreshing(WeatherViewState)
    case error(String)
}
