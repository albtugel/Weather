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
                UIColor(hex: "#2e6fa3").cgColor
            ]
        case .daySunny:
            return [
                UIColor(hex: "#1a5fa0").cgColor
            ]
        case .eveningSunny:
            return [
                UIColor(hex: "#1a4f80").cgColor
            ]
        case .nightSunny:
            return [
                UIColor(hex: "#1a2a50").cgColor
            ]
        case .morningRainy, .dayRainy:
            return [
                UIColor(hex: "#2a3d4e").cgColor
            ]
        case .eveningRainy:
            return [
                UIColor(hex: "#1e2d3a").cgColor
            ]
        case .nightRainy:
            return [
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
