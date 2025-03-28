//
//  MapViewController.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 18.03.2025.
//

import UIKit
import SnapKit
import MapboxMaps
import MapboxSearch
import MapboxSearchUI

class MapViewController: UIViewController {
    
    var mapView: MapView!
    private lazy var trackingButton = UIButton(frame: .zero)
    
    private var lastCameraCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
    private var lastZoom: CGFloat = 8
    
    private var annotationManager: PointAnnotationManager?
    let aqiService = AQIService()
    
    //    let secondViewController = SecondViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.addChild(secondViewController) // TODO: read about it
        //        secondViewController.didMove(toParent: self)
        
        setupMapView()
        setupTrackingButton()
        centerMapOnUserLocationOrFallback()
        
        setupCameraListener()
    }
}

// MARK: MapView Setup
private extension MapViewController {
    func setupMapView() {
        let fallbackCamera = CameraOptions(center: lastCameraCenter, zoom: lastZoom)
        let initOptions = MapInitOptions(cameraOptions: fallbackCamera, styleURI: .standard)
        
        mapView = MapView(frame: view.bounds, mapInitOptions: initOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
        mapView.location.options.puckType = .puck2D()
        
        let bounds = CameraBoundsOptions(maxZoom: 14.0, minZoom: 3.0)
        try? mapView.mapboxMap.setCameraBounds(with: bounds)
    }
    
    func setupCameraListener() {
        mapView.mapboxMap.onEvery(event: .mapIdle) { [weak self] _ in
            guard let self = self else { return }
            
            let cameraState = self.mapView.mapboxMap.cameraState
            let center = cameraState.center
            let zoom = cameraState.zoom
            
            let centerThreshold: CLLocationDegrees = 0.03
            let zoomThreshold: CGFloat = 0.4
            
            let latDiff = abs(center.latitude - self.lastCameraCenter.latitude)
            let lonDiff = abs(center.longitude - self.lastCameraCenter.longitude)
            let zoomDiff = abs(zoom - self.lastZoom)
            
            if latDiff < centerThreshold && lonDiff < centerThreshold && zoomDiff < zoomThreshold {
                return
            }
            
            self.lastCameraCenter = center
            self.lastZoom = zoom
            
            self.updateMapAQIData()
        }
    }
    
    // MARK: Location Handling
    func centerMapOnUserLocationOrFallback() {
        if let location = mapView.location.latestLocation {
            moveCamera(to: location.coordinate, zoom: 12)
        } else {
            // Ждём первое обновление в течение 2 секунд, иначе fallback
            // TODO: make it to wait for 2 sec
            var didCenter = false
            let observer = mapView.location.onLocationChange.observeNext { [weak self] locations in
                guard let coordinate = locations.last?.coordinate else { return }
                guard didCenter == false else { return }
                didCenter = true
                self?.moveCamera(to: coordinate, zoom: 12)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                observer.cancel()
                guard let self = self else { return }
                if didCenter == false {
                    print("⚠️ Не удалось получить локацию — fallback на Алматы")
                    self.moveCamera(to: self.lastCameraCenter, zoom: self.lastZoom)
                }
            }
        }
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
    
    // MARK: Helpers
    func moveCamera(to coordinate: CLLocationCoordinate2D, zoom: CGFloat) {
        mapView.camera.ease(to: CameraOptions(center: coordinate, zoom: zoom), duration: 1.2)
        
        self.lastCameraCenter = coordinate
        self.lastZoom = zoom
        
        updateMapAQIData()
    }
    
    // TODO: move to MapManager
    func updateMapAQIData() {
        aqiService.fetchAQIData(mapView: mapView) { [weak self] markers in
            guard let self = self, let markers = markers else { return }
            
            DispatchQueue.main.async {
                self.addAQIMarkers(markers)
            }
        }
    }
    
    func addAQIMarkers(_ markers: [AQIMarker]) {
        annotationManager?.annotations.removeAll()
        
        if annotationManager == nil {
            annotationManager = mapView.annotations.makePointAnnotationManager()
        }
        
        var annotations: [PointAnnotation] = []
        
        for marker in markers {
            var annotation = PointAnnotation(coordinate: CLLocationCoordinate2D(
                latitude: marker.coordinates.latitude,
                longitude: marker.coordinates.longitude
            ))
            
            annotation.image = .init(image: makeCircleImage(color: color(for: marker.aqi)), name: UUID().uuidString)
            annotation.textField = "\(marker.aqi)"
            annotation.textSize = 12
            annotation.textAnchor = .top
            
            annotations.append(annotation)
        }
        
        annotationManager?.annotations = annotations
    }
    
    func color(for aqi: Int) -> UIColor {
        switch aqi {
        case 0...50: return .systemGreen
        case 51...100: return .systemYellow
        case 101...150: return .systemOrange
        case 151...200: return .systemRed
        case 201...300: return .purple
        default: return .brown
        }
    }
    
    func makeCircleImage(color: UIColor, diameter: CGFloat = 30) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return renderer.image { ctx in
            let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
            ctx.cgContext.setFillColor(color.cgColor)
            ctx.cgContext.fillEllipse(in: rect)
        }
    }
}
