import UIKit
import Combine
import SnapKit

final class WeatherViewController: UIViewController {
    private let viewModel = WeatherViewModel()
    private let screenView = WeatherScreenView()
    private let citiesButton = UIButton(type: .system)
    private let refreshControl = UIRefreshControl()
    private var cancellables = Set<AnyCancellable>()

    override func loadView() {
        view = screenView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        screenView.scrollView.delegate = self
        configureRefreshControl()
        configureCitiesButton()
        bindViewModel()
        viewModel.viewDidLoad()
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

    private func configureCitiesButton() {
        let image = UIImage(systemName: "list.bullet")
        citiesButton.setImage(image, for: .normal)
        citiesButton.tintColor = .white
        citiesButton.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        citiesButton.layer.cornerRadius = 22
        citiesButton.addTarget(self, action: #selector(openCities), for: .touchUpInside)

        view.addSubview(citiesButton)

        citiesButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.size.equalTo(44)
        }
    }

    @objc private func openCities() {
        let controller = CitiesController()
        controller.onCitySelected = { [weak self] city in
            self?.navigationController?.popViewController(animated: true)
            self?.viewModel.loadCity(city)
        }

        navigationController?.pushViewController(controller, animated: true)
    }

    private func render(_ state: WeatherScreenState) {
        switch state {
        case .loading:
            refreshControl.endRefreshing()
            screenView.showLoading()
        case let .content(viewState):
            refreshControl.endRefreshing()
            screenView.showContent(viewState)
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
