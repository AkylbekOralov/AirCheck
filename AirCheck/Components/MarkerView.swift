//
//  MarkerView.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 05.04.2025.
//

import UIKit
import SnapKit

class MarkerView: UIView {
    private let aqiNumber = UILabel()
    
    init(number: Int, diameter: CGFloat = 30) {
        super.init(frame: .zero)
        setupView(number: number, diameter: diameter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(number: Int, diameter: CGFloat) {
        // Set size using SnapKit
        self.snp.makeConstraints { make in
            make.width.height.equalTo(diameter)
        }
        
        // Circular style
        self.layer.cornerRadius = diameter / 2
        self.backgroundColor = AQIColorHelper.color(for: number)
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor
        
        // Shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
        
        // Label
        aqiNumber.text = "\(number)"
        aqiNumber.textAlignment = .center
        aqiNumber.textColor = .black
        aqiNumber.font = UIFont.boldSystemFont(ofSize: 14)
        
        addSubview(aqiNumber)
        
        aqiNumber.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
