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
        view.backgroundColor = AQIHelper.backgroundColor(for: 0)
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let aqiBox: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let aqiLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        return label
    }()
    
    private let aqiSubLabel: UILabel = {
        let label = UILabel()
        label.text = "US AQI"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.8)
        label.textAlignment = .center
        return label
    }()
    
    private let statusStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white.withAlphaComponent(0.9)
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let faceImageView: UIImageView = {
        let imageView = UIImageView()
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
        containerView.addSubview(statusStack)
        containerView.addSubview(faceImageView)
        
        let aqiStack = UIStackView(arrangedSubviews: [aqiLabel, aqiSubLabel])
        aqiStack.axis = .vertical
        aqiStack.alignment = .center
        aqiStack.spacing = 4
        aqiBox.addSubview(aqiStack)

        aqiBox.snp.makeConstraints { make in
            make.size.equalTo(70)
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        aqiStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        statusStack.addArrangedSubview(statusLabel)
        statusStack.addArrangedSubview(messageLabel)
        
        statusStack.snp.makeConstraints { make in
            make.leading.equalTo(aqiBox.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
        }
        
        faceImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
    
    func update(withAQI aqi: Int) {
        aqiLabel.text = "\(aqi)"
        statusLabel.text = AQIHelper.state(for: aqi)
        messageLabel.text = AQIHelper.message(for: aqi)
        faceImageView.image = UIImage(named: AQIHelper.image(for: aqi))
        containerView.backgroundColor = AQIHelper.backgroundColor(for: aqi)
        aqiBox.backgroundColor = AQIHelper.secondBackgroundColor(for: aqi)
    }
}
