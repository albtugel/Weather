import Foundation

enum TemperatureUnit: String {
    case celsius = "celsius"
    case fahrenheit = "fahrenheit"
}

extension Double {
    func formatted(unit: TemperatureUnit) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.unitOptions = .temperatureWithoutUnit
        formatter.numberFormatter.maximumFractionDigits = 0

        let celsius = Measurement(value: self, unit: UnitTemperature.celsius)

        switch unit {
        case .celsius:
            return formatter.string(from: celsius.converted(to: .celsius))
        case .fahrenheit:
            return formatter.string(from: celsius.converted(to: .fahrenheit))
        }
    }
}
