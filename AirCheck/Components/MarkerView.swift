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
    
    private let contentView = UIView()
    
    var isSelected: Bool = false {
        didSet {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.6,
                options: [.curveEaseInOut],
                animations: {
                    self.contentView.transform = self.isSelected
                    ? CGAffineTransform(scaleX: 1.2, y: 1.2)
                    : .identity
                },
                completion: nil
            )
        }
    }
    
    init(number: Int, diameter: CGFloat = 30, coordinate: CLLocationCoordinate2D) {
        self.aqiNumber = number
        self.coordinate = coordinate
        super.init(frame: CGRect(x: 0, y: 0, width: diameter, height: diameter))
        setupView(diameter: diameter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    private func setupView(diameter: CGFloat) {
    //        contentView.frame = bounds
    //
    //        self.layer.cornerRadius = diameter / 2
    //        self.backgroundColor = AQIHelper.color(for: aqiNumber)
    //        self.layer.borderWidth = 2
    //        self.layer.borderColor = UIColor.white.cgColor
    //
    //        self.layer.shadowColor = UIColor.black.cgColor
    //        self.layer.shadowOpacity = 0.25
    //        self.layer.shadowOffset = CGSize(width: 0, height: 2)
    //        self.layer.shadowRadius = 4
    //        self.layer.masksToBounds = false
    //
    //        aqiNumberLabel.text = "\(aqiNumber)"
    //        aqiNumberLabel.textAlignment = .center
    //        aqiNumberLabel.textColor = .black
    //        aqiNumberLabel.font = UIFont.boldSystemFont(ofSize: 14)
    //
    //        addSubview(aqiNumberLabel)
    //
    //        aqiNumberLabel.snp.makeConstraints { make in
    //            make.center.equalToSuperview()
    //        }
    //    }
    
    private func setupView(diameter: CGFloat) {
        contentView.frame = bounds
        contentView.layer.cornerRadius = diameter / 2
        contentView.backgroundColor = AQIHelper.color(for: aqiNumber)
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.white.cgColor
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.25
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        contentView.clipsToBounds = false
        
        addSubview(contentView)
        
        aqiNumberLabel.text = "\(aqiNumber)"
        aqiNumberLabel.textAlignment = .center
        aqiNumberLabel.textColor = .black
        aqiNumberLabel.font = UIFont.boldSystemFont(ofSize: 14)
        
        contentView.addSubview(aqiNumberLabel)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        aqiNumberLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
