import Foundation

enum WeatherDetailFormatting {
    static func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    static func pressureString(_ value: Int) -> String {
        let string = String(value)
        guard string.count > 3 else { return string }
        let index = string.index(string.endIndex, offsetBy: -3)
        return "\(string[..<index]) \(string[index...])"
    }

    static func pressureTrendText(_ trend: String) -> String {
        switch trend {
        case "falling": return "↓ гПА"
        case "rising": return "↑ гПА"
        default: return "→ гПА"
        }
    }

    static func formattedAverageDelta(_ text: String) -> String {
        guard AppSettings.shared.temperatureUnit == .fahrenheit else { return text }
        let pattern = "[-+]?\\d+°?"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range, in: text) else {
            return text
        }

        let matched = String(text[range]).replacingOccurrences(of: "°", with: "")
        let sign: String
        if matched.hasPrefix("-") {
            sign = "-"
        } else if matched.hasPrefix("+") {
            sign = "+"
        } else {
            sign = ""
        }

        let valueString = matched.trimmingCharacters(in: CharacterSet(charactersIn: "+-"))
        guard let value = Double(valueString) else { return text }
        let converted = value * 9 / 5
        let formatted = "\(sign)\(Int(converted.rounded()))°"
        return text.replacingCharacters(in: range, with: formatted)
    }
}
