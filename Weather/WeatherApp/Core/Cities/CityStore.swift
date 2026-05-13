import Foundation

final class CityStore {
    private let key = "cities"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func all() -> [City] {
        guard let data = userDefaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([City].self, from: data)) ?? []
    }

    func save(_ cities: [City]) {
        let sorted = cities.sorted {
            $0.isCurrent && !$1.isCurrent
        }

        guard let data = try? JSONEncoder().encode(sorted) else { return }
        userDefaults.set(data, forKey: key)
    }

    func upsert(_ city: City) {
        var cities = all()
        cities.removeAll { $0.id == city.id }
        cities.append(city)
        save(cities)
    }

    func remove(id: String) {
        guard id != City.currentId else { return }

        var cities = all()
        cities.removeAll { $0.id == id && !$0.isCurrent }
        save(cities)
    }
}
