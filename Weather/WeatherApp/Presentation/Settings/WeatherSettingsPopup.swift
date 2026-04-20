import UIKit
import SnapKit

protocol WeatherSettingsPopupDelegate: AnyObject {
    func weatherSettingsPopupDidSelectEditList(_ popup: WeatherSettingsPopup)
    func weatherSettingsPopupDidSelectNotifications(_ popup: WeatherSettingsPopup)
    func weatherSettingsPopupDidSelectUnits(_ popup: WeatherSettingsPopup)
    func weatherSettingsPopupDidSelectReport(_ popup: WeatherSettingsPopup)
    func weatherSettingsPopupDidRequestDismiss(_ popup: WeatherSettingsPopup)
}

final class WeatherSettingsPopup: UIView {
    weak var delegate: WeatherSettingsPopupDelegate?

    private let stackView = UIStackView()
    private let celsiusRow = SettingsRowView()
    private let fahrenheitRow = SettingsRowView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
        updateCheckmarks()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(temperatureUnitChanged),
            name: .temperatureUnitChanged,
            object: nil
        )
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupLayout()
        updateCheckmarks()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(temperatureUnitChanged),
            name: .temperatureUnitChanged,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupView() {
        backgroundColor = UIColor(hex: "#1c2b3a")
        layer.cornerRadius = 14
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 20
        layer.shadowOffset = CGSize(width: 0, height: 10)

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let editRow = SettingsRowView()
        editRow.configure(
            icon: .symbol(name: "pencil"),
            title: "Изменить список",
            showsCheckmark: false
        )
        editRow.setSeparatorVisible(true)
        editRow.addTarget(self, action: #selector(editTapped), for: .touchUpInside)

        let notificationsRow = SettingsRowView()
        notificationsRow.configure(
            icon: .symbol(name: "bell"),
            title: "Уведомления",
            showsCheckmark: false
        )
        notificationsRow.setSeparatorVisible(true)
        notificationsRow.addTarget(self, action: #selector(notificationsTapped), for: .touchUpInside)

        celsiusRow.configure(
            icon: .text("°C"),
            title: "Градусы Цельсия",
            showsCheckmark: true
        )
        celsiusRow.setSeparatorVisible(true)
        celsiusRow.addTarget(self, action: #selector(celsiusTapped), for: .touchUpInside)

        fahrenheitRow.configure(
            icon: .text("°F"),
            title: "Градусы Фаренгейта",
            showsCheckmark: true
        )
        fahrenheitRow.setSeparatorVisible(true)
        fahrenheitRow.addTarget(self, action: #selector(fahrenheitTapped), for: .touchUpInside)

        let unitsRow = SettingsRowView()
        unitsRow.configure(
            icon: .symbol(name: "chart.bar.fill"),
            title: "Единицы",
            showsCheckmark: false
        )
        unitsRow.setSeparatorVisible(true)
        unitsRow.addTarget(self, action: #selector(unitsTapped), for: .touchUpInside)

        let reportRow = SettingsRowView()
        reportRow.configure(
            icon: .symbol(name: "exclamationmark.bubble"),
            title: "Сообщить о проблеме",
            showsCheckmark: false
        )
        reportRow.setSeparatorVisible(false)
        reportRow.addTarget(self, action: #selector(reportTapped), for: .touchUpInside)

        let rows: [UIView] = [
            editRow,
            notificationsRow,
            celsiusRow,
            fahrenheitRow,
            unitsRow,
            reportRow
        ]

        rows.forEach { stackView.addArrangedSubview($0) }
    }

    private func setupLayout() {
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func animateIn() {
        setAnchorPoint(CGPoint(x: 1, y: 0))
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        let timing = UISpringTimingParameters(damping: 0.75, response: 0.35)
        let animator = UIViewPropertyAnimator(duration: 0.22, timingParameters: timing)
        animator.addAnimations {
            self.alpha = 1
            self.transform = .identity
        }
        animator.startAnimation()
    }

    func animateOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseIn], animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }, completion: { _ in
            completion()
        })
    }

    private func setAnchorPoint(_ point: CGPoint) {
        let oldOrigin = frame.origin
        layer.anchorPoint = point
        let newOrigin = frame.origin
        let transition = CGPoint(x: newOrigin.x - oldOrigin.x, y: newOrigin.y - oldOrigin.y)
        center = CGPoint(x: center.x - transition.x, y: center.y - transition.y)
    }

    private func updateCheckmarks() {
        let unit = AppSettings.shared.temperatureUnit
        celsiusRow.setCheckmarkVisible(unit == .celsius)
        fahrenheitRow.setCheckmarkVisible(unit == .fahrenheit)
    }

    @objc private func temperatureUnitChanged() {
        updateCheckmarks()
    }

    @objc private func editTapped() {
        delegate?.weatherSettingsPopupDidSelectEditList(self)
        delegate?.weatherSettingsPopupDidRequestDismiss(self)
    }

    @objc private func notificationsTapped() {
        delegate?.weatherSettingsPopupDidSelectNotifications(self)
        delegate?.weatherSettingsPopupDidRequestDismiss(self)
    }

    @objc private func celsiusTapped() {
        AppSettings.shared.temperatureUnit = .celsius
        updateCheckmarks()
        delegate?.weatherSettingsPopupDidRequestDismiss(self)
    }

    @objc private func fahrenheitTapped() {
        AppSettings.shared.temperatureUnit = .fahrenheit
        updateCheckmarks()
        delegate?.weatherSettingsPopupDidRequestDismiss(self)
    }

    @objc private func unitsTapped() {
        delegate?.weatherSettingsPopupDidSelectUnits(self)
        delegate?.weatherSettingsPopupDidRequestDismiss(self)
    }

    @objc private func reportTapped() {
        delegate?.weatherSettingsPopupDidSelectReport(self)
        delegate?.weatherSettingsPopupDidRequestDismiss(self)
    }
}

private final class SettingsRowView: UIControl {
    enum Icon {
        case symbol(name: String)
        case text(String)
    }

    private let iconImageView = UIImageView()
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let checkmarkView = UIImageView()
    private let separatorView = UIView()
    private var titleLeadingToImage: Constraint?
    private var titleLeadingToText: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupLayout()
    }

    private func setupView() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        snp.makeConstraints { make in
            make.height.equalTo(44)
        }

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = UIColor.white.withAlphaComponent(0.8)
        iconImageView.contentMode = .scaleAspectFit

        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.font = .systemFont(ofSize: 15, weight: .regular)
        iconLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        iconLabel.isHidden = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = .white

        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkView.image = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .medium))
        checkmarkView.tintColor = .white
        checkmarkView.isHidden = true

        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        separatorView.isHidden = true
    }

    private func setupLayout() {
        addSubview(iconImageView)
        addSubview(iconLabel)
        addSubview(titleLabel)
        addSubview(checkmarkView)
        addSubview(separatorView)

        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(18)
        }

        iconLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            
            self.titleLeadingToImage = make.leading.equalTo(iconImageView.snp.trailing).offset(12).constraint
            self.titleLeadingToText = make.leading.equalTo(iconLabel.snp.trailing).offset(12).constraint
            
            self.titleLeadingToImage?.deactivate()
            self.titleLeadingToText?.deactivate()
        }

        checkmarkView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.size.equalTo(14)
        }

        separatorView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    func configure(icon: Icon, title: String, showsCheckmark: Bool) {
        switch icon {
        case .symbol(let name):
            iconLabel.isHidden = true
            iconImageView.isHidden = false
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
            iconImageView.image = UIImage(systemName: name, withConfiguration: config)
            titleLeadingToText?.deactivate()
            titleLeadingToImage?.activate()
        case .text(let text):
            iconImageView.isHidden = true
            iconLabel.isHidden = false
            iconLabel.text = text
            titleLeadingToImage?.deactivate()
            titleLeadingToText?.activate()
        }

        titleLabel.text = title
        checkmarkView.isHidden = !showsCheckmark
    }

    func setCheckmarkVisible(_ visible: Bool) {
        checkmarkView.isHidden = !visible
    }

    func setSeparatorVisible(_ visible: Bool) {
        separatorView.isHidden = !visible
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

private extension UISpringTimingParameters {
    convenience init(damping: CGFloat, response: CGFloat) {
        let safeResponse = max(response, 0.01)
        let mass: CGFloat = 1
        let stiffness = pow(2 * .pi / safeResponse, 2) * mass
        let dampingCoefficient = 4 * .pi * damping * mass / safeResponse
        self.init(mass: mass, stiffness: stiffness, damping: dampingCoefficient, initialVelocity: .zero)
    }
}
