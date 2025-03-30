//
//  MapViewController.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 18.03.2025.
//

import UIKit
import SnapKit

class MapViewController: UIViewController {
    private var mapManager: MapManager!
    private var searchManager: MapSearchManager!
    
    // Location button
    private lazy var trackingButton = UIButton(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapManager = MapManager(container: view)
        setupTrackingButton()
        
        searchManager = MapSearchManager(mapView: mapManager.mapView, presentingViewController: self)
        searchManager.presentSearchUI()
    }
}

private extension MapViewController {
    // MARK: Location Button
    func setupTrackingButton() {
        trackingButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        trackingButton.tintColor = .systemBlue
        trackingButton.backgroundColor = UIColor(white: 0.97, alpha: 1)
        trackingButton.layer.cornerRadius = 22
        trackingButton.layer.shadowColor = UIColor.black.cgColor
        trackingButton.layer.shadowOpacity = 0.3
        trackingButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        trackingButton.layer.shadowRadius = 2
        
        trackingButton.addTarget(self, action: #selector(centerMapOnUserLocation), for: .touchUpInside)
        
        view.addSubview(trackingButton)
        
        trackingButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(48)
            make.width.height.equalTo(44)
        }
    }
    
    @objc func centerMapOnUserLocation() {
        mapManager.centerMapOnUserLocation()
    }
}
