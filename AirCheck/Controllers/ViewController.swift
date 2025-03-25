//
//  ViewController.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 18.03.2025.
//

import UIKit
import SnapKit
import MapboxMaps

class ViewController: UIViewController {
    
    var mapView: MapView!
    private lazy var trackingButton = UIButton(frame: .zero)
    
    private var lastCameraCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
    private var lastZoom: CGFloat = 8
    
    private var annotationManager: PointAnnotationManager?
    let aqiService = AQIService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupTrackingButton()
        centerMapOnUserLocationOrFallback()
        
        setupCameraListener()
    }
}

// MapView Setup
extension ViewController {
    private func setupMapView() {
        let fallbackCamera = CameraOptions(center: lastCameraCenter, zoom: lastZoom)
        let initOptions = MapInitOptions(cameraOptions: fallbackCamera, styleURI: .standard)
        
        mapView = MapView(frame: view.bounds, mapInitOptions: initOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.location.options.puckType = .puck2D()
        
        let bounds = CameraBoundsOptions(maxZoom: 14.0, minZoom: 3.0)
        try? mapView.mapboxMap.setCameraBounds(with: bounds)
    }
    
    private func setupCameraListener() {
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
            
            self.fetchAQIDataAndDisplay()
        }
    }
}

// Location Handling
extension ViewController {
    private func centerMapOnUserLocationOrFallback() {
        if let location = mapView.location.latestLocation {
            moveCamera(to: location.coordinate, zoom: 12)
        } else {
            // Ждём первое обновление в течение 2 секунд, иначе fallback
            var didCenter = false
            let observer = mapView.location.onLocationChange.observeNext { [weak self] locations in
                guard let coordinate = locations.last?.coordinate else { return }
                guard didCenter == false else { return }
                didCenter = true
                self?.moveCamera(to: coordinate, zoom: 12)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self else { return }
                if didCenter == false {
                    print("⚠️ Не удалось получить локацию — fallback на Алматы")
                    self.moveCamera(to: self.lastCameraCenter, zoom: self.lastZoom)
                }
                observer.cancel()
            }
        }
    }
    
    @objc private func centerMapOnUserLocation() {
        if let location = mapView.location.latestLocation {
            moveCamera(to: location.coordinate, zoom: 12)
        } else {
            _ = mapView.location.onLocationChange.observeNext { [weak self] locations in
                guard let coordinate = locations.last?.coordinate else { return }
                self?.moveCamera(to: coordinate, zoom: 12)
            }
        }
    }
}

// Location Button
extension ViewController {
    private func setupTrackingButton() {
        trackingButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        trackingButton.tintColor = .systemBlue
        trackingButton.backgroundColor = UIColor(white: 0.97, alpha: 1)
        trackingButton.layer.cornerRadius = 22
        trackingButton.layer.shadowColor = UIColor.black.cgColor
        trackingButton.layer.shadowOpacity = 0.3
        trackingButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        trackingButton.layer.shadowRadius = 2
        
        trackingButton.addTarget(self, action: #selector(centerMapOnUserLocation), for: .touchUpInside)
        
        trackingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackingButton)
        
        NSLayoutConstraint.activate([
            trackingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            trackingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -48),
            trackingButton.widthAnchor.constraint(equalToConstant: 44),
            trackingButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

// Helpers
extension ViewController {
    private func moveCamera(to coordinate: CLLocationCoordinate2D, zoom: CGFloat) {
        mapView.camera.ease(to: CameraOptions(center: coordinate, zoom: zoom), duration: 1.2)

        self.lastCameraCenter = coordinate
        self.lastZoom = zoom

        fetchAQIDataAndDisplay()
    }
    
    private func fetchAQIDataAndDisplay() {
        aqiService.fetchAQIData(mapView: mapView) { [weak self] markers in
            guard let self = self, let markers = markers else { return }

            DispatchQueue.main.async {
                self.addAQIMarkers(markers)
            }
        }
    }
    
    private func addAQIMarkers(_ markers: [AQIMarker]) {
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
    
    private func color(for aqi: Int) -> UIColor {
        switch aqi {
        case 0...50: return .systemGreen
        case 51...100: return .systemYellow
        case 101...150: return .systemOrange
        case 151...200: return .systemRed
        case 201...300: return .purple
        default: return .brown
        }
    }

    private func makeCircleImage(color: UIColor, diameter: CGFloat = 30) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return renderer.image { ctx in
            let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
            ctx.cgContext.setFillColor(color.cgColor)
            ctx.cgContext.fillEllipse(in: rect)
        }
    }
}
