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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupTrackingButton()
        centerMapOnUserLocationOrFallback()
        
        setupCameraListener()
    }
    
    private func setupMapView() {
        let fallbackCamera = CameraOptions(center: lastCameraCenter, zoom: lastZoom)
        let initOptions = MapInitOptions(cameraOptions: fallbackCamera, styleURI: .standard)
        
        mapView = MapView(frame: view.bounds, mapInitOptions: initOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
        // Show blue location dot
        mapView.location.options.puckType = .puck2D()
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

            // Просто вызываем нашу общую функцию
            printVisibleRegionInfo(mapView: self.mapView)
        }
    }
    
    func printVisibleRegionInfo(mapView: MapView) {
        let cameraState = mapView.mapboxMap.cameraState
        let center = cameraState.center
        let zoom = cameraState.zoom

        let cameraOptions = CameraOptions(center: center, zoom: zoom)
        let bounds = try? mapView.mapboxMap.coordinateBounds(for: cameraOptions)

        if let bounds = bounds {
            let north = bounds.northeast.latitude
            let south = bounds.southwest.latitude
            let east = bounds.northeast.longitude
            let west = bounds.southwest.longitude

            print("🌍 Видимая область карты:")
            print("  Север (Top): \(north)")
            print("  Юг (Bottom): \(south)")
            print("  Восток (Right): \(east)")
            print("  Запад (Left): \(west)")
            print("🔍 Zoom Level: \(zoom)")
            print("——————————")
        } else {
            print("⚠️ Не удалось получить границы карты.")
        }
    }
    
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
            
            // Fallback через 2 секунды
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
    
    private func moveCamera(to coordinate: CLLocationCoordinate2D, zoom: CGFloat) {
        mapView.camera.ease(to: CameraOptions(center: coordinate, zoom: zoom), duration: 1.2)
        
        // Обновим lastCameraCenter и zoom
        self.lastCameraCenter = coordinate
        self.lastZoom = zoom
        
        printVisibleRegionInfo(mapView: self.mapView)
    }
    
}
