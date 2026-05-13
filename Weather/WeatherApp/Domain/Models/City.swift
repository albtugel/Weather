import Foundation

struct City: Codable, Equatable {
    let id: String
    let name: String
    let subtitle: String?
    let lat: Double
    let lon: Double
    let isCurrent: Bool

    static let currentId = "current"
}
