//
//  MapManager.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 26.03.2025.
//

import MapboxMaps
import UIKit

final class MapManager {
    var mapView: MapView
    private var aqiAnnotationManager: PointAnnotationManager?
    private let aqiService = AQIService()
    
    var lastCameraCenter: CLLocationCoordinate2D
    var lastZoom: CGFloat
    
    init(container: UIView) {
        self.lastCameraCenter = CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
        self.lastZoom = 8

        let startCameraCenter = CameraOptions(center: lastCameraCenter, zoom: lastZoom)
        let initOptions = MapInitOptions(cameraOptions: startCameraCenter, styleURI: .standard)
        
        self.mapView = MapView(frame: container.bounds, mapInitOptions: initOptions)
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mapView.location.options.puckType = .puck2D()
        
        container.addSubview(mapView)
        
        setupCameraBounds()
        setupCameraListener()
        centerMapOnUserLocation()
        
    }
    
    private func setupCameraBounds() {
        let bounds = CameraBoundsOptions(maxZoom: 14.0, minZoom: 3.0)
        try? mapView.mapboxMap.setCameraBounds(with: bounds)
    }
    
    private func setupCameraListener() {
        mapView.mapboxMap.onEvery(event: .mapIdle) { [weak self] _ in
            guard let self = self else { return }
            
            let cameraState = mapView.mapboxMap.cameraState
            let center = cameraState.center
            let zoom = cameraState.zoom
            
            let latDiff = abs(center.latitude - lastCameraCenter.latitude)
            let lonDiff = abs(center.longitude - lastCameraCenter.longitude)
            let zoomDiff = abs(zoom - lastZoom)
            
            if latDiff < 0.03 && lonDiff < 0.03 && zoomDiff < 0.4 {
                return
            }
            
            lastCameraCenter = center
            lastZoom = zoom
            
            updateAQIData()
        }
    }
    
    private func centerMapOnUserLocationOrFallback() {
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
    
    func centerMapOnUserLocation() {
        if let location = mapView.location.latestLocation {
            moveCamera(to: location.coordinate, zoom: 12)
        } else {
            _ = mapView.location.onLocationChange.observeNext { [weak self] locations in
                guard let coordinate = locations.last?.coordinate else { return }
                self?.moveCamera(to: coordinate, zoom: 12)
            }
        }
    }
    
    // TODO: why "to coordinate"
    func moveCamera(to coordinate: CLLocationCoordinate2D, zoom: CGFloat) {
        mapView.camera.ease(to: CameraOptions(center: coordinate, zoom: zoom), duration: 1.2)
        
        self.lastCameraCenter = coordinate
        self.lastZoom = zoom
        
        updateAQIData()
    }
    
    private func updateAQIData() {
        aqiService.fetchAQIData(mapView: mapView) { [weak self] markers in
            guard let self, let markers else { return }
            DispatchQueue.main.async {
                self.addAQIMarkers(markers)
            }
        }
    }
    
    private func addAQIMarkers(_ markers: [AQIMarker]) {
        if aqiAnnotationManager == nil {
            aqiAnnotationManager = mapView.annotations.makePointAnnotationManager()
        } else {
            aqiAnnotationManager?.annotations.removeAll()
        }
        
        let annotations = markers.map { marker -> PointAnnotation in
            var annotation = PointAnnotation(
                coordinate: CLLocationCoordinate2D(
                    latitude: marker.coordinates.latitude,
                    longitude: marker.coordinates.longitude
                )
            )
            annotation.image = .init(
                image: UIImage.circleImage(color: AQIColorHelper.color(for: marker.aqi)),
                name: UUID().uuidString
            )
            annotation.textField = "\(marker.aqi)"
            annotation.textSize = 12
            annotation.textAnchor = .top
            return annotation
        }
        
        aqiAnnotationManager?.annotations = annotations
    }
}
