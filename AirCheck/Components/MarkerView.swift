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
    private var sizeConstraint: Constraint?
    
    init(number: Int, diameter: CGFloat = 30, coordinate: CLLocationCoordinate2D) {
        self.aqiNumber = number
        self.coordinate = coordinate
        super.init(frame: .zero)
        setupView(diameter: diameter)
    }
    
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                scaleUpView()
            } else {
                returnToOriginalScale()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(diameter: CGFloat) {
        self.snp.makeConstraints { make in
            make.width.height.equalTo(diameter)
        }
        
        self.layer.cornerRadius = diameter / 2
        self.backgroundColor = AQIHelper.color(for: aqiNumber)
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
    
    private func scaleUpView() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }
    }

    private func returnToOriginalScale() {
        UIView.animate(withDuration: 0.2) {
            // Reset the view to its original scale
            self.transform = .identity
        }
    }
}
