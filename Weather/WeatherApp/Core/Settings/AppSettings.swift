import Foundation

final class AppSettings {
    static let shared = AppSettings()
    private init() {}

    private let key = "temperature_unit"

    var temperatureUnit: TemperatureUnit {
        get {
            Locale.autoupdatingCurrent.usesMetricSystem ? .celsius : .fahrenheit
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
            NotificationCenter.default.post(name: .temperatureUnitChanged, object: nil)
        }
    }
}

extension Notification.Name {
    static let temperatureUnitChanged = Notification.Name("temperatureUnitChanged")
}
