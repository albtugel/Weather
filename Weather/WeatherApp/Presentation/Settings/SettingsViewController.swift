import UIKit
import SnapKit

final class SettingsViewController: UIViewController {
    private let handleView = UIView()
    private let tableView = UITableView(frame: .zero, style: .plain)

    private let items: [SettingsItem] = [
        .icon(symbol: "pencil", title: "Изменить список", showsCheckmark: false),
        .icon(symbol: "bell", title: "Уведомления", showsCheckmark: false),
        .unit(text: "°C", title: "Градусы Цельсия", showsCheckmark: true),
        .unit(text: "°F", title: "Градусы Фаренгейта", showsCheckmark: false),
        .icon(symbol: "chart.bar", title: "Единицы", showsCheckmark: false),
        .icon(symbol: "message", title: "Сообщить о проблеме", showsCheckmark: false)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
    }

    private func setupView() {
        view.backgroundColor = UIColor(hex: "#1a2a3a")
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true

        handleView.translatesAutoresizingMaskIntoConstraints = false
        handleView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        handleView.layer.cornerRadius = 2

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor.white.withAlphaComponent(0.15)
        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero
        tableView.rowHeight = 52
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.reuseID)
    }

    private func setupLayout() {
        view.addSubview(handleView)
        view.addSubview(tableView)

        handleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 36, height: 4))
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(handleView.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reuseID, for: indexPath) as? SettingsCell else {
            return UITableViewCell()
        }
        cell.configure(with: items[indexPath.row])
        return cell
    }
}

private enum SettingsItem {
    case icon(symbol: String, title: String, showsCheckmark: Bool)
    case unit(text: String, title: String, showsCheckmark: Bool)

    var title: String {
        switch self {
        case .icon(_, let title, _),
             .unit(_, let title, _):
            return title
        }
    }

    var showsCheckmark: Bool {
        switch self {
        case .icon(_, _, let shows),
             .unit(_, _, let shows):
            return shows
        }
    }
}

private final class SettingsCell: UITableViewCell {
    static let reuseID = "SettingsCell"

    private let iconImageView = UIImageView()
    private let unitLabel = UILabel()
    private let titleLabel = UILabel()
    private let checkmarkView = UIImageView()
    private var titleLeadingToIcon: Constraint?
    private var titleLeadingToUnit: Constraint?

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

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = UIColor.white.withAlphaComponent(0.8)

        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        unitLabel.font = .systemFont(ofSize: 20, weight: .medium)
        unitLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        unitLabel.isHidden = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = .white

        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        let checkConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        checkmarkView.image = UIImage(systemName: "checkmark", withConfiguration: checkConfig)
        checkmarkView.tintColor = .white
        checkmarkView.isHidden = true
    }

    private func setupLayout() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(unitLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkView)

        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }

        unitLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            titleLeadingToIcon = make.leading.equalTo(iconImageView.snp.trailing).offset(12).constraint
            titleLeadingToUnit = make.leading.equalTo(unitLabel.snp.trailing).offset(12).constraint
        }

        checkmarkView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
    }

    func configure(with item: SettingsItem) {
        switch item {
        case .icon(let symbol, let title, let showsCheckmark):
            unitLabel.isHidden = true
            iconImageView.isHidden = false
            iconImageView.image = UIImage(
                systemName: symbol,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            )
            titleLabel.text = title
            titleLeadingToUnit?.deactivate()
            titleLeadingToIcon?.activate()
            checkmarkView.isHidden = !showsCheckmark
        case .unit(let text, let title, let showsCheckmark):
            iconImageView.isHidden = true
            unitLabel.isHidden = false
            unitLabel.text = text
            titleLabel.text = title
            titleLeadingToIcon?.deactivate()
            titleLeadingToUnit?.activate()
            checkmarkView.isHidden = !showsCheckmark
        }
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
