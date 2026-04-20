import Foundation
enum AppConfig {
    static var apiKey: String {
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["WeatherAPIKey"] as? String else {
            fatalError("Keys.plist not found.")
        }
        return key
    }
}
