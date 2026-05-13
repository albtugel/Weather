import Combine
import SnapKit
import UIKit
internal import _LocationEssentials

final class Pager: UIViewController {
    private let pages = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private let dots = Dots()
    private let citiesButton = UIButton(type: .system)

    private let store: CityStore
    private let locationManager: LocationManagerProtocol
    private var cities: [City] = []
    private var currentIndex = 0
    private var currentCityId: String?
    private var controllers: [String: WeatherViewController] = [:]
    private var emptyPage: WeatherViewController?
    private var list: CitiesController?
    private var cancellables = Set<AnyCancellable>()

    init(
        store: CityStore = DIContainer.shared.cityStore,
        locationManager: LocationManagerProtocol = DIContainer.shared.locationManager
    ) {
        self.store = store
        self.locationManager = locationManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.store = DIContainer.shared.cityStore
        self.locationManager = DIContainer.shared.locationManager
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupPages()
        setupControls()
        bind()
        reload(animated: false)
        locationManager.requestLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func setupPages() {
        addChild(pages)
        view.addSubview(pages.view)
        pages.didMove(toParent: self)

        pages.dataSource = self
        pages.delegate = self

        pages.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupControls() {
        let image = UIImage(systemName: "list.bullet")
        citiesButton.setImage(image, for: .normal)
        citiesButton.tintColor = .white
        citiesButton.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        citiesButton.layer.cornerRadius = 22
        citiesButton.addTarget(self, action: #selector(openList), for: .touchUpInside)

        view.addSubview(dots)
        view.addSubview(citiesButton)

        dots.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }

        citiesButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(dots)
            make.size.equalTo(44)
        }
    }

    private func bind() {
        NotificationCenter.default.publisher(for: .citiesChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reload(animated: true)
            }
            .store(in: &cancellables)

        locationManager.statusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handle(status)
            }
            .store(in: &cancellables)
    }

    private func handle(_ status: LocationStatus) {
        guard case let .authorized(location) = status else { return }

        if let current = store.all().first(where: { $0.isCurrent }) {
            let samePlace = abs(current.lat - location.coordinate.latitude) < 0.0005
                && abs(current.lon - location.coordinate.longitude) < 0.0005
            if samePlace { return }
        }

        store.upsert(
            City(
                id: City.currentId,
                name: "Текущее место",
                subtitle: nil,
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude,
                isCurrent: true
            )
        )
    }

    private func reload(animated: Bool) {
        let oldId = currentCityId
        let oldIndex = currentIndex
        cities = store.all()
        keepCurrentControllers()

        if cities.isEmpty {
            currentIndex = 0
            currentCityId = nil
            pages.setViewControllers([page(for: nil)], direction: .forward, animated: false)
            dots.render(count: 0, index: 0, hasLocation: false)
            return
        }

        if let oldId = oldId, let index = cities.firstIndex(where: { $0.id == oldId }) {
            currentIndex = index
        } else {
            currentIndex = min(oldIndex, cities.count - 1)
        }

        currentCityId = cities[currentIndex].id
        let direction: UIPageViewController.NavigationDirection = currentIndex >= oldIndex ? .forward : .reverse
        pages.setViewControllers([page(for: cities[currentIndex])], direction: direction, animated: animated)
        renderDots()
    }

    private func keepCurrentControllers() {
        var kept: [String: WeatherViewController] = [:]

        for city in cities {
            kept[city.id] = controllers[city.id]
        }

        controllers = kept
    }

    private func renderDots() {
        dots.render(count: cities.count, index: currentIndex, hasLocation: cities.first?.isCurrent == true)
    }

    private func page(for city: City?) -> WeatherViewController {
        guard let city else {
            if let controller = emptyPage {
                return controller
            }

            let controller = WeatherViewController(city: nil)
            emptyPage = controller
            return controller
        }

        if let controller = controllers[city.id] {
            return controller
        }

        let controller = WeatherViewController(city: city)
        controllers[city.id] = controller
        return controller
    }

    @objc private func openList() {
        guard list == nil else { return }
        Haptics.light()

        let controller = CitiesController()
        controller.onClose = { [weak self] in
            self?.closeList()
        }
        controller.onCitySelected = { [weak self] city in
            self?.show(city)
            self?.closeList()
        }

        list = controller
        addChild(controller)
        view.addSubview(controller.view)
        controller.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.layoutIfNeeded()
        controller.didMove(toParent: self)

        controller.view.alpha = 0
        controller.view.transform = CGAffineTransform(translationX: 0, y: 30)

        UIView.animate(withDuration: 0.32, delay: 0, options: [.curveEaseOut]) {
            self.pages.view.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
            self.pages.view.alpha = 0.72
            controller.view.alpha = 1
            controller.view.transform = .identity
        }
    }

    private func closeList() {
        guard let controller = list else { return }
        Haptics.light()

        UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseOut]) {
            self.pages.view.transform = .identity
            self.pages.view.alpha = 1
            controller.view.alpha = 0
            controller.view.transform = CGAffineTransform(translationX: 0, y: 30)
        } completion: { _ in
            controller.willMove(toParent: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParent()
            self.list = nil
        }
    }

    private func show(_ city: City) {
        guard let index = cities.firstIndex(where: { $0.id == city.id }) else { return }
        let direction: UIPageViewController.NavigationDirection = index >= currentIndex ? .forward : .reverse
        currentIndex = index
        currentCityId = city.id
        pages.setViewControllers([page(for: city)], direction: direction, animated: false)
        renderDots()
    }
}

extension Pager: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = index(of: viewController), index > 0 else { return nil }
        return page(for: cities[index - 1])
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = index(of: viewController), index < cities.count - 1 else { return nil }
        return page(for: cities[index + 1])
    }
}

extension Pager: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed, let controller = pageViewController.viewControllers?.first, let index = index(of: controller) else {
            return
        }

        currentIndex = index
        currentCityId = cities[index].id
        renderDots()
        Haptics.light()
    }

    private func index(of controller: UIViewController) -> Int? {
        guard let controller = controller as? WeatherViewController, let city = controller.city else {
            return nil
        }

        return cities.firstIndex(of: city)
    }
}
