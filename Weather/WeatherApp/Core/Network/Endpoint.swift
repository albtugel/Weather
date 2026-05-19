import Foundation

struct Endpoint {
    let path: String
    let method: String
    let queryItems: [URLQueryItem]
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = path
        
        var items = queryItems
        items.append(URLQueryItem(name: "appid", value: AppConfig.apiKey))
        items.append(URLQueryItem(name: "units", value: "metric"))
        items.append(URLQueryItem(name: "lang", value: "ru"))
        components.queryItems = items
        
        return components.url
    }
    
    static func oneCall(lat: Double, lon: Double) -> Endpoint {
        Endpoint(
            path: "/data/3.0/onecall",
            method: "GET",
            queryItems: [
                URLQueryItem(name: "lat", value: String(lat)),
                URLQueryItem(name: "lon", value: String(lon)),
                URLQueryItem(name: "exclude", value: "minutely,alerts")
            ]
        )
    }
    
    static func weather(lat: Double, lon: Double) -> Endpoint {
        Endpoint(
            path: "/data/2.5/weather",
            method: "GET",
            queryItems: [
                URLQueryItem(name: "lat", value: String(lat)),
                URLQueryItem(name: "lon", value: String(lon))
            ]
        )
    }
}
