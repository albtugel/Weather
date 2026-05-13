import SnapKit
import UIKit

final class SearchField: UIView {
    let textField = UITextField()

    var onChange: ((String) -> Void)?

    private let iconView = UIImageView()
    private let clearButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupLayout()
    }

    func clear() {
        textField.text = ""
        clearButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        onChange?("")
    }

    private func setupViews() {
        backgroundColor = UIColor.white.withAlphaComponent(0.14)
        layer.cornerRadius = 18
        layer.borderWidth = 0

        iconView.image = UIImage(systemName: "magnifyingglass")
        iconView.tintColor = UIColor.white.withAlphaComponent(0.78)

        textField.borderStyle = .none
        textField.textColor = .white
        textField.tintColor = .white
        textField.font = .systemFont(ofSize: 18, weight: .semibold)
        textField.returnKeyType = .search
        textField.autocorrectionType = .no
        textField.clearButtonMode = .never
        textField.attributedPlaceholder = NSAttributedString(
            string: "Поиск города или аэропорта",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.58)]
        )

        clearButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        clearButton.tintColor = UIColor.white.withAlphaComponent(0.78)

        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
    }

    private func setupLayout() {
        addSubview(iconView)
        addSubview(textField)
        addSubview(clearButton)

        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(22)
        }

        clearButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }

        textField.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(14)
            make.trailing.equalTo(clearButton.snp.leading).offset(-14)
            make.top.bottom.equalToSuperview()
        }
    }

    @objc private func textChanged() {
        let text = textField.text ?? ""
        let imageName = text.isEmpty ? "mic.fill" : "xmark.circle.fill"
        clearButton.setImage(UIImage(systemName: imageName), for: .normal)
        onChange?(text)
    }

    @objc private func clearTapped() {
        guard !(textField.text ?? "").isEmpty else { return }
        clear()
    }
}
