//
//  RowSeparatorView.swift
//  Weather
//
//  Created by Alik on 21/4/26.
//

import UIKit
import SnapKit

final class RowSeparatorView: UIView {
    private let line = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { nil }

    private func setup() {
        line.backgroundColor = .white.withAlphaComponent(0.15)
        addSubview(line)

        snp.makeConstraints { make in make.height.equalTo(0.5) }
        line.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}
