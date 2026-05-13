import UIKit
import Combine
import SnapKit

final class WeatherViewController: UIViewController {
    let city: City?

    private let viewModel = WeatherViewModel()
    private let screenView = WeatherScreenView()
    private let refreshControl = UIRefreshControl()
    private var cancellables = Set<AnyCancellable>()

    init(city: City? = nil) {
        self.city = city
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.city = nil
        super.init(coder: coder)
    }

    override func loadView() {
        view = screenView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        screenView.scrollView.delegate = self
        configureRefreshControl()
        bindViewModel()

        if let city {
            viewModel.loadCity(city)
        } else {
            viewModel.viewDidLoad()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(temperatureUnitChanged),
            name: .temperatureUnitChanged,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func bindViewModel() {
        viewModel.screenState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }

    @objc private func temperatureUnitChanged() {
        viewModel.refreshForCurrentUnit()
    }

    @objc private func handleRefresh() {
        viewModel.refresh()
    }

    private func configureRefreshControl() {
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        screenView.scrollView.refreshControl = refreshControl
    }

    private func render(_ state: WeatherScreenState) {
        switch state {
        case .loading:
            refreshControl.endRefreshing()
            screenView.showLoading()
        case let .content(viewState):
            refreshControl.endRefreshing()
            screenView.showContent(viewState)
            screenView.showFirstAppearance()
        case let .refreshing(viewState):
            screenView.showRefreshing(viewState)
        }
    }
}

extension WeatherViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        screenView.updateHeaderProgress(for: scrollView.contentOffset.y)
    }
}
