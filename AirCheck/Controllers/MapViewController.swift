//
//  MapViewController.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 18.03.2025.
//

import UIKit
import SnapKit
import MapboxMaps

class MapViewController: UIViewController {
    var mapView: MapView!
    private var mapManager: MapManager!
    
    private lazy var trackingButton = UIButton(frame: .zero)
    
    let initialCameraCoordinate = CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
    let initialZoom = CGFloat(10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        mapManager = MapManager(mapView: mapView, lastCameraCenter: initialCameraCoordinate, lastZoom: initialZoom)
        centerMapOnUserLocation()
        
        setupTrackingButton()
    }
}

private extension MapViewController {
    func setupMapView() {
        let startCameraCenter = CameraOptions(center: initialCameraCoordinate, zoom: initialZoom)
        let initOptions = MapInitOptions(cameraOptions: startCameraCenter, styleURI: .standard)
        
        self.mapView = MapView(frame: view.bounds, mapInitOptions: initOptions)
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mapView.location.options.puckType = .puck2D()
        
        view.addSubview(mapView)
        
        // Camera Bounds
        let bounds = CameraBoundsOptions(maxZoom: 14.0, minZoom: 3.0)
        try? self.mapView.mapboxMap.setCameraBounds(with: bounds)
    }
    
    @objc func centerMapOnUserLocation() {
        if let location = mapView.location.latestLocation {
            moveCamera(to: location.coordinate, zoom: 12)
        } else {
            _ = mapView.location.onLocationChange.observeNext { [weak self] locations in
                guard let coordinate = locations.last?.coordinate else { return }
                self?.moveCamera(to: coordinate, zoom: 12)
            }
        }
    }
    
    func moveCamera(to coordinate: CLLocationCoordinate2D, zoom: CGFloat) {
        self.mapManager.updateMapCameraCenter(coordinate: coordinate, zoom: zoom)
        self.mapView.camera.ease(to: CameraOptions(center: coordinate, zoom: zoom), duration: 1.2)
    }
    
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
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(48)
            make.width.height.equalTo(44)
        }
    }
}
