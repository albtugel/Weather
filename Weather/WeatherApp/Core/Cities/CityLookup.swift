import Combine
import MapKit

final class CityLookup: NSObject {
    let results = CurrentValueSubject<[MKLocalSearchCompletion], Never>([])
    let errors = PassthroughSubject<Error, Never>()

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }

    func search(_ query: String) {
        completer.queryFragment = query
    }

    func clear() {
        completer.queryFragment = ""
        results.send([])
    }

    func city(from completion: MKLocalSearchCompletion) async throws -> City {
        let request = MKLocalSearch.Request(completion: completion)
        let response = try await MKLocalSearch(request: request).start()

        guard let item = response.mapItems.first else {
            throw CityLookupError.emptyResult
        }

        let coordinate = item.placemark.coordinate
        let name = item.placemark.locality ?? item.name ?? completion.title
        let subtitle = item.placemark.country ?? completion.subtitle

        return City(
            id: "\(coordinate.latitude),\(coordinate.longitude)",
            name: name,
            subtitle: subtitle.isEmpty ? nil : subtitle,
            lat: coordinate.latitude,
            lon: coordinate.longitude,
            isCurrent: false
        )
    }
}

extension CityLookup: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results.send(completer.results)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        errors.send(error)
    }
}

enum CityLookupError: Error {
    case emptyResult
}
