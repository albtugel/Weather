import UIKit

enum WeatherBackground {
    case morningSunny      // 06:00–10:00, no rain
    case daySunny          // 10:00–18:00, no rain
    case eveningSunny      // 18:00–24:00, no rain
    case nightSunny        // 00:00–06:00, no rain
    case morningRainy      // 06:00–10:00, rain
    case dayRainy          // 10:00–18:00, rain
    case eveningRainy      // 18:00–24:00, rain
    case nightRainy        // 00:00–06:00, rain

    var gradientColors: [CGColor] {
        switch self {
        case .morningSunny:
            return [
                UIColor(hex: "#e8f4fc").cgColor,
                UIColor(hex: "#a8d4f0").cgColor,
                UIColor(hex: "#5a9fd4").cgColor,
                UIColor(hex: "#2e6fa3").cgColor
            ]
        case .daySunny:
            return [
                UIColor(hex: "#d4eaf7").cgColor,
                UIColor(hex: "#7ab8e0").cgColor,
                UIColor(hex: "#3a87c8").cgColor,
                UIColor(hex: "#1a5fa0").cgColor
            ]
        case .eveningSunny:
            return [
                UIColor(hex: "#c8dff0").cgColor,
                UIColor(hex: "#6aaad8").cgColor,
                UIColor(hex: "#2d7ab8").cgColor,
                UIColor(hex: "#1a4f80").cgColor
            ]
        case .nightSunny:
            return [
                UIColor(hex: "#0d1530").cgColor,
                UIColor(hex: "#111d40").cgColor,
                UIColor(hex: "#152348").cgColor,
                UIColor(hex: "#1a2a50").cgColor
            ]
        case .morningRainy, .dayRainy:
            return [
                UIColor(hex: "#3a4a58").cgColor,
                UIColor(hex: "#4a5d6e").cgColor,
                UIColor(hex: "#3d5060").cgColor,
                UIColor(hex: "#2a3d4e").cgColor
            ]
        case .eveningRainy:
            return [
                UIColor(hex: "#2a3540").cgColor,
                UIColor(hex: "#3a4a58").cgColor,
                UIColor(hex: "#2d3e4e").cgColor,
                UIColor(hex: "#1e2d3a").cgColor
            ]
        case .nightRainy:
            return [
                UIColor(hex: "#0f1520").cgColor,
                UIColor(hex: "#1a2530").cgColor,
                UIColor(hex: "#152030").cgColor,
                UIColor(hex: "#0f1820").cgColor
            ]
        }
    }

    var locations: [NSNumber] {
        [0.0, 0.35, 0.7, 1.0]
    }

    static func current(conditionCode: Int, date: Date = Date()) -> WeatherBackground {
        let hour = Calendar.current.component(.hour, from: date)
        let isRain = (200...599).contains(conditionCode)

        switch hour {
        case 6..<10:  return isRain ? .morningRainy : .morningSunny
        case 10..<18: return isRain ? .dayRainy    : .daySunny
        case 18..<24: return isRain ? .eveningRainy : .eveningSunny
        default:      return isRain ? .nightRainy  : .nightSunny
        }
    }

    func sunGlowLayer(in bounds: CGRect) -> CARadialGradientLayer? {
        guard self == .morningSunny || self == .daySunny else { return nil }
        let layer = CARadialGradientLayer()
        layer.frame = bounds
        layer.colors = [
            UIColor.white.withAlphaComponent(0.9).cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        layer.startPoint = CGPoint(x: 0.5, y: 0.15)
        layer.endPoint = CGPoint(x: 0.8, y: 0.15)
        return layer
    }
}

final class CARadialGradientLayer: CAGradientLayer {
    override init() {
        super.init()
        type = .radial
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        type = .radial
    }
}

private extension UIColor {
    convenience init(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") {
            cleaned.removeFirst()
        }

        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
