import UIKit
import SnapKit

final class WeatherTabBar: UIView {
    private let mapButton = UIButton(type: .system)
    private let locationPill = UIControl()
    private let locationIconView = UIImageView()

    var onMapTap: (() -> Void)?
    var onLocationTap: (() -> Void)?

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

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 49 + safeAreaInsets.bottom)
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        invalidateIntrinsicContentSize()
    }

    private func setupView() {
        backgroundColor = .clear

        mapButton.translatesAutoresizingMaskIntoConstraints = false
        mapButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        mapButton.layer.cornerRadius = 22
        mapButton.tintColor = .white
        let mapConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        mapButton.setImage(UIImage(systemName: "map", withConfiguration: mapConfig), for: .normal)
        mapButton.addTarget(self, action: #selector(handleMapTap), for: .touchUpInside)

        locationPill.translatesAutoresizingMaskIntoConstraints = false
        locationPill.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        locationPill.layer.cornerRadius = 22
        locationPill.addTarget(self, action: #selector(handleLocationTap), for: .touchUpInside)
        locationPill.isUserInteractionEnabled = false

        locationIconView.translatesAutoresizingMaskIntoConstraints = false
        let locConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        locationIconView.image = UIImage(systemName: "location.fill", withConfiguration: locConfig)
        locationIconView.tintColor = .white
    }

    private func setupLayout() {
        addSubview(mapButton)
        addSubview(locationPill)

        locationPill.addSubview(locationIconView)

        mapButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(44)
        }

        locationPill.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(44)
        }

        locationIconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(12)
        }
    }

    @objc private func handleMapTap() {
        animateTap(mapButton)
        onMapTap?()
    }

    @objc private func handleLocationTap() {
        onLocationTap?()
    }

    private func animateTap(_ view: UIView) {
        UIView.animate(withDuration: 0.1, animations: {
            view.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.1, delay: 0.1, options: [], animations: {
                view.transform = .identity
            }, completion: nil)
        }
    }
}
