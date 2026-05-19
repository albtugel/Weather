import Foundation

final class WeatherService {
    
    static let shared = WeatherService()
    private let api: APIClientProtocol
    
    private init(api: APIClientProtocol = APIClient()) {
        self.api = api
    }
    
    func oneCall(lat: Double, lon: Double) async throws -> OneCallResponse {
        let endpoint = Endpoint.oneCall(lat: lat, lon: lon)
        return try await api.request(endpoint)
    }
}
