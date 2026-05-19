import Foundation

enum AppConfig {
    static var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let key = dict["WeatherAPIKey"] as? String else {
            fatalError("Keys.plist with WeatherAPIKey is missing in target")
        }
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.lowercased() != "your_api_key" else {
            fatalError("WeatherAPIKey is empty or placeholder. Provide a valid OpenWeather key.")
        }
        return trimmed
    }
}
