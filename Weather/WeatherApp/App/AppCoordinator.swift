import UIKit

final class AppCoordinator {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        window.rootViewController = UINavigationController(rootViewController: WeatherViewController())
        window.makeKeyAndVisible()
    }
}
