import Combine
import CoreLocation

enum LocationStatus {
    case notDetermined
    case denied
    case authorized(CLLocation)
    case failed(Error)
}

protocol LocationManagerProtocol {
    var statusPublisher: AnyPublisher<LocationStatus, Never> { get }
    func requestLocation()
}
