//
//  MarkerView.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 05.04.2025.
//

import UIKit
import CoreLocation
import SnapKit

class MarkerView: UIView {
    private let aqiNumberLabel = UILabel()
    var aqiNumber: Int
    var coordinate: CLLocationCoordinate2D
    
    init(number: Int, diameter: CGFloat = 30, coordinate: CLLocationCoordinate2D) {
        self.aqiNumber = number
        self.coordinate = coordinate
        super.init(frame: .zero)
        setupView(diameter: diameter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(diameter: CGFloat) {
        self.snp.makeConstraints { make in
            make.width.height.equalTo(diameter)
        }
        
        self.layer.cornerRadius = diameter / 2
        self.backgroundColor = AQIColorHelper.color(for: aqiNumber)
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
        
        aqiNumberLabel.text = "\(aqiNumber)"
        aqiNumberLabel.textAlignment = .center
        aqiNumberLabel.textColor = .black
        aqiNumberLabel.font = UIFont.boldSystemFont(ofSize: 14)
        
        addSubview(aqiNumberLabel)
        
        aqiNumberLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
