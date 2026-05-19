import Foundation

struct MockWeatherData {
    
    struct Current {
        let city: String
        let locationType: String
        let temp: Int
        let desc: String
        let high: Int
        let low: Int
        let conditionCode: Int
        let summary: String
    }
    
    struct Hourly {
        let label: String
        let temp: Int?
        let icon: String
        let isSunset: Bool
    }
    
    struct Daily {
        let day: String
        let icon: String
        let low: Int
        let high: Int
    }
    
    struct City {
        let name: String
        let type: String?
        let time: String?
        let condition: String
        let high: Int
        let low: Int
        let temp: Int
    }
    
    static let current = Current(
        city: "Алматы",
        locationType: "ТЕКУЩЕЕ МЕСТО",
        temp: 11,
        desc: "В основном солнечно",
        high: 11,
        low: 5,
        conditionCode: 801,
        summary: "Солнечно до конца дня."
    )
    
    static let hourly: [Hourly] = makeHourly()
    static let daily: [Daily] = makeDaily()
    
    static let cities: [City] = [
        City(name: "Алматы", type: "Текущее место", time: nil,
             condition: "В основном солнечно", high: 11, low: 5, temp: 11),
        
        City(name: "Астана", type: nil, time: currentTime(),
             condition: "В основном облачно", high: -10, low: -22, temp: -10),
        
        City(name: "Алматы", type: nil, time: currentTime(),
             condition: "В основном солнечно", high: 22, low: 8, temp: 22)
    ]
    
    private static func currentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
    
    private static func makeHourly() -> [Hourly] {
        let now = Date()
        let calendar = Calendar.current
        
        var items: [Hourly] = [
            Hourly(label: "Сейчас", temp: 11, icon: "sun.max.fill", isSunset: false)
        ]
        
        for hour in 1...15 {
            let date = calendar.date(byAdding: .hour, value: hour, to: now) ?? now
            let hourString = String(calendar.component(.hour, from: date))
            
            items.append(Hourly(
                label: hourString,
                temp: 10 - hour/3,
                icon: hour >= 18 ? "moon.fill" : "sun.max.fill",
                isSunset: false
            ))
        }
        
        items.insert(Hourly(label: "17:29", temp: nil, icon: "sunset.fill", isSunset: true), at: 3)
        
        return items
    }
    
    private static func makeDaily() -> [Daily] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("EEE")
        
        let startDate = calendar.startOfDay(for: Date())
        let templates = [
            ("sun.max.fill", 5, 11),
            ("cloud.rain.fill", 2, 9),
            ("cloud.fill", 0, 9),
            ("cloud.fill", -2, 9),
            ("cloud.fill", -4, -1),
            ("cloud.fill", -4, 0),
            ("cloud.rain.fill", -4, 0),
            ("cloud.fill", -4, 1),
            ("cloud.fill", -3, 2),
            ("sun.max.fill", -2, 2)
        ]
        
        return templates.enumerated().map { index, item in
            let day = index == 0
                ? NSLocalizedString("Сегодня", comment: "")
                : formatter.string(from: calendar.date(byAdding: .day, value: index, to: startDate)!).capitalized
            
            return Daily(day: day, icon: item.0, low: item.1, high: item.2)
        }
    }
}
