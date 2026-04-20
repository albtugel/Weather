import UIKit
import Combine

final class WeatherViewController: UIViewController {
    private let viewModel = WeatherViewModel()
    private let screenView = WeatherScreenView()
    private var cancellables = Set<AnyCancellable>()

    override func loadView() {
        view = screenView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        screenView.scrollView.delegate = self
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
        viewModel.viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.screenView.render(state)
            }
            .store(in: &cancellables)
    }

    @objc private func temperatureUnitChanged() {
        viewModel.refreshForCurrentUnit()
    }
}

extension WeatherViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        screenView.updateHeaderProgress(for: scrollView.contentOffset.y)
    }
}
