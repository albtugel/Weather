import Foundation

enum TemperatureUnit: String {
    case celsius = "celsius"
    case fahrenheit = "fahrenheit"
}

extension Double {
    func formatted(unit: TemperatureUnit) -> String {
        switch unit {
        case .celsius:
            return "\(Int(self.rounded()))°"
        case .fahrenheit:
            let f = self * 9 / 5 + 32
            return "\(Int(f.rounded()))°"
        }
    }
}
