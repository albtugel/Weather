import UIKit
import SnapKit

final class WeatherTabBar: UIView {
    private let mapButton = UIButton(type: .system)
    private let listButton = UIButton(type: .system)
    private let locationPill = UIControl()
    private let locationIconView = UIImageView()
    private let dotsStack = UIStackView()
    private let activeDot = UIView()
    private let inactiveDot1 = UIView()
    private let inactiveDot2 = UIView()

    var onMapTap: (() -> Void)?
    var onListTap: (() -> Void)?
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

        listButton.translatesAutoresizingMaskIntoConstraints = false
        listButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        listButton.layer.cornerRadius = 22
        listButton.tintColor = .white
        let listConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        listButton.setImage(UIImage(systemName: "list.bullet", withConfiguration: listConfig), for: .normal)
        listButton.addTarget(self, action: #selector(handleListTap), for: .touchUpInside)

        locationPill.translatesAutoresizingMaskIntoConstraints = false
        locationPill.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        locationPill.layer.cornerRadius = 22
        locationPill.addTarget(self, action: #selector(handleLocationTap), for: .touchUpInside)

        locationIconView.translatesAutoresizingMaskIntoConstraints = false
        let locConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        locationIconView.image = UIImage(systemName: "location.fill", withConfiguration: locConfig)
        locationIconView.tintColor = .white

        dotsStack.translatesAutoresizingMaskIntoConstraints = false
        dotsStack.axis = .horizontal
        dotsStack.alignment = .center
        dotsStack.spacing = 4

        configureDot(activeDot, size: 4, alpha: 0.9)
        configureDot(inactiveDot1, size: 3, alpha: 0.6)
        configureDot(inactiveDot2, size: 3, alpha: 0.6)

        dotsStack.addArrangedSubview(activeDot)
        dotsStack.addArrangedSubview(inactiveDot1)
        dotsStack.addArrangedSubview(inactiveDot2)
    }

    private func setupLayout() {
        addSubview(mapButton)
        addSubview(locationPill)
        addSubview(listButton)

        locationPill.addSubview(locationIconView)
        locationPill.addSubview(dotsStack)

        mapButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(44)
        }

        listButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(44)
        }

        locationPill.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(44)
        }

        locationIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(12)
        }

        dotsStack.snp.makeConstraints { make in
            make.leading.equalTo(locationIconView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    private func configureDot(_ view: UIView, size: CGFloat, alpha: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        view.layer.cornerRadius = size / 2
        view.snp.makeConstraints { make in
            make.size.equalTo(size)
        }
    }

    @objc private func handleMapTap() {
        animateTap(mapButton)
        onMapTap?()
    }

    @objc private func handleListTap() {
        animateTap(listButton)
        onListTap?()
    }

    @objc private func handleLocationTap() {
        animateTap(locationPill)
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
