import Combine
import CoreLocation

final class LocationManager: NSObject, LocationManagerProtocol, CLLocationManagerDelegate {
    private let manager: CLLocationManager
    private let subject = PassthroughSubject<LocationStatus, Never>()

    override init() {
        self.manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    var statusPublisher: AnyPublisher<LocationStatus, Never> {
        subject.eraseToAnyPublisher()
    }

    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            subject.send(.notDetermined)
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            subject.send(.denied)
        @unknown default:
            subject.send(.denied)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            subject.send(.notDetermined)
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            subject.send(.denied)
        @unknown default:
            subject.send(.denied)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            subject.send(.authorized(location))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        subject.send(.failed(error))
    }
}
