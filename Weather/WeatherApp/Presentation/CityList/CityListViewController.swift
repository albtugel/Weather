import UIKit
import SnapKit
import UserNotifications

final class CityListViewController: UIViewController {
    private let gradientLayer = CAGradientLayer()

    private let titleLabel = UILabel()
    private let optionsButton = UIButton(type: .system)
    private let doneButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchBar = UISearchBar()

    private let footerLabel = UILabel()

    private let cardColors: [UIColor] = [
        UIColor(hex: "#233445").withAlphaComponent(0.6),
        UIColor(hex: "#1f3142").withAlphaComponent(0.6),
        UIColor(hex: "#24384a").withAlphaComponent(0.6),
        UIColor(hex: "#203242").withAlphaComponent(0.6)
    ]

    private var cities = MockWeatherData.cities
    private var popupOverlay: UIView?
    private var settingsPopup: WeatherSettingsPopup?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupViews()
        setupLayout()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(temperatureUnitChanged),
            name: .temperatureUnitChanged,
            object: nil
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupBackground() {
        view.backgroundColor = UIColor(hex: "#1a2a3a")
        gradientLayer.colors = [
            UIColor(hex: "#1a2a3a").cgColor,
            UIColor(hex: "#0f1b28").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupViews() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Погода"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = .white

        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        let optionsConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        optionsButton.setImage(UIImage(systemName: "ellipsis.circle", withConfiguration: optionsConfig), for: .normal)
        optionsButton.tintColor = .white
        optionsButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)

        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        doneButton.isHidden = true
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 112
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tintColor = .white
        tableView.register(CityCardCell.self, forCellReuseIdentifier: CityCardCell.reuseID)

        footerLabel.text = "Подробнее о метеорологических и картографических данных"
        footerLabel.font = .systemFont(ofSize: 12, weight: .regular)
        footerLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        footerLabel.textAlignment = .center
        footerLabel.numberOfLines = 0
        footerLabel.isUserInteractionEnabled = true
        footerLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFooterTap)))

        let footerContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 40))
        footerContainer.backgroundColor = .clear
        footerContainer.addSubview(footerLabel)
        footerLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        tableView.tableFooterView = footerContainer

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Поиск города или аэропорта"
        searchBar.searchBarStyle = .minimal
        searchBar.barTintColor = .clear
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Поиск города или аэропорта",
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.6)
            ]
        )

        let micConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        let micView = UIImageView(image: UIImage(systemName: "mic.fill", withConfiguration: micConfig))
        micView.tintColor = UIColor.white.withAlphaComponent(0.7)
        searchBar.searchTextField.rightView = micView
        searchBar.searchTextField.rightViewMode = .always
        searchBar.searchTextField.leftView?.tintColor = UIColor.white.withAlphaComponent(0.7)
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(optionsButton)
        view.addSubview(doneButton)
        view.addSubview(tableView)
        view.addSubview(searchBar)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
        }

        optionsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.size.equalTo(28)
        }

        doneButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }

        searchBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(searchBar.snp.top).offset(-8)
        }
    }

    @objc private func handleFooterTap() {
    }

    @objc private func moreButtonTapped() {
        showSettingsPopup()
    }

    @objc private func doneButtonTapped() {
        tableView.setEditing(false, animated: true)
        optionsButton.isHidden = false
        doneButton.isHidden = true
    }

    @objc private func temperatureUnitChanged() {
        tableView.reloadData()
    }

    private func showSettingsPopup() {
        guard let window = view.window else { return }

        dismissPopup()

        let overlay = UIView(frame: UIScreen.main.bounds)
        overlay.backgroundColor = .clear
        overlay.tag = 999
        overlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissPopup)))

        let popup = WeatherSettingsPopup()
        popup.delegate = self

        let buttonFrame = optionsButton.convert(optionsButton.bounds, to: nil)
        let popupX = buttonFrame.maxX - 250
        let popupY = buttonFrame.maxY + 8
        popup.frame = CGRect(x: popupX, y: popupY, width: 250, height: 264)

        window.addSubview(overlay)
        window.addSubview(popup)

        popupOverlay = overlay
        settingsPopup = popup

        popup.animateIn()
    }

    @objc private func dismissPopup() {
        if let popup = settingsPopup {
            popup.animateOut {
                popup.removeFromSuperview()
            }
        }
        settingsPopup = nil
        popupOverlay?.removeFromSuperview()
        popupOverlay = nil
    }
}

extension CityListViewController: WeatherSettingsPopupDelegate {
    func weatherSettingsPopupDidSelectEditList(_ popup: WeatherSettingsPopup) {
        dismissPopup()
        tableView.setEditing(true, animated: true)
        optionsButton.isHidden = true
        doneButton.isHidden = false
    }

    func weatherSettingsPopupDidSelectNotifications(_ popup: WeatherSettingsPopup) {
        dismissPopup()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                } else if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }

    func weatherSettingsPopupDidSelectUnits(_ popup: WeatherSettingsPopup) {
        dismissPopup()
        let controller = UnitsViewController()
        controller.modalPresentationStyle = .pageSheet
        present(controller, animated: true)
    }

    func weatherSettingsPopupDidSelectReport(_ popup: WeatherSettingsPopup) {
        dismissPopup()
        if let url = URL(string: "mailto:support@example.com?subject=Weather%20App%20Problem") {
            UIApplication.shared.open(url)
        }
    }

    func weatherSettingsPopupDidRequestDismiss(_ popup: WeatherSettingsPopup) {
        dismissPopup()
    }
}

extension CityListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CityCardCell.reuseID, for: indexPath) as? CityCardCell else {
            return UITableViewCell()
        }
        let model = cities[indexPath.row]
        cell.configure(with: model, backgroundColor: cardColors[indexPath.row % cardColors.count])
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = cities.remove(at: sourceIndexPath.row)
        cities.insert(item, at: destinationIndexPath.row)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            cities.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

private final class CityCardCell: UITableViewCell {
    static let reuseID = "CityCardCell"

    private let cardView = UIView()
    private let cityLabel = UILabel()
    private let locationLabel = UILabel()
    private let conditionLabel = UILabel()
    private let highLowLabel = UILabel()
    private let tempLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupLayout()
    }

    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true

        cityLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        cityLabel.textColor = .white

        locationLabel.font = .systemFont(ofSize: 14, weight: .regular)
        locationLabel.textColor = UIColor.white.withAlphaComponent(0.7)

        conditionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        conditionLabel.textColor = UIColor.white.withAlphaComponent(0.8)

        highLowLabel.font = .systemFont(ofSize: 12, weight: .regular)
        highLowLabel.textColor = UIColor.white.withAlphaComponent(0.6)

        tempLabel.font = .systemFont(ofSize: 52, weight: .thin)
        tempLabel.textColor = .white
        tempLabel.textAlignment = .right
    }

    private func setupLayout() {
        contentView.addSubview(cardView)

        cardView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(104)
        }

        let leftStack = UIStackView(arrangedSubviews: [
            cityLabel,
            locationLabel,
            conditionLabel,
            highLowLabel
        ])
        leftStack.axis = .vertical
        leftStack.alignment = .leading
        leftStack.spacing = 2
        leftStack.translatesAutoresizingMaskIntoConstraints = false

        tempLabel.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(leftStack)
        cardView.addSubview(tempLabel)

        leftStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(tempLabel.snp.leading).offset(-8)
        }

        tempLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    func configure(with model: MockWeatherData.CityWeather, backgroundColor: UIColor) {
        let unit = AppSettings.shared.temperatureUnit
        cityLabel.text = model.name
        if let type = model.type {
            locationLabel.text = type
        } else if let time = model.time {
            locationLabel.text = time
        } else {
            locationLabel.text = ""
        }
        conditionLabel.text = model.condition
        let high = Double(model.high).formatted(unit: unit)
        let low = Double(model.low).formatted(unit: unit)
        highLowLabel.text = "Макс.: \(high), мин.: \(low)"
        tempLabel.text = Double(model.temp).formatted(unit: unit)
        cardView.backgroundColor = backgroundColor
    }
}

private extension UIColor {
    convenience init(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") {
            cleaned.removeFirst()
        }

        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
