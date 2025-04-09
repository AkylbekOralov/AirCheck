//
//  PopUpView.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 08.04.2025.
//

import UIKit
import SnapKit

class AQIPopUpView: UIView {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.157, green: 0.212, blue: 0.094, alpha: 1)
        view.layer.cornerRadius = 12
        return view
    }()

    private let aqiBox: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.376, green: 0.424, blue: 0.22, alpha: 1)
        view.layer.cornerRadius = 8
        return view
    }()

    private let aqiLabel: UILabel = {
        let label = UILabel()
        label.text = "27"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()

    private let aqiSubLabel: UILabel = {
        let label = UILabel()
        label.text = "US AQI"
        label.font = .systemFont(ofSize: 10)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Good"
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()

    private let faceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "smile")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        containerView.addSubview(aqiBox)
        containerView.addSubview(statusLabel)
        containerView.addSubview(faceImageView)

        let aqiStack = UIStackView(arrangedSubviews: [aqiLabel, aqiSubLabel])
        aqiStack.axis = .vertical
        aqiStack.alignment = .center
        aqiStack.spacing = 2
        aqiBox.addSubview(aqiStack)

        aqiBox.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        aqiStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        statusLabel.snp.makeConstraints { make in
            make.leading.equalTo(aqiBox.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
        }

        faceImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(30)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
    }

    func update(withAQI aqi: Int) {
        aqiLabel.text = "\(aqi)"
    }
}
