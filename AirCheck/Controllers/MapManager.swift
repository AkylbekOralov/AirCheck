//
//  MapManager.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 26.03.2025.
//

import MapboxMaps
import UIKit

final class MapManager {
    let mapView: MapView!
    private(set) var aqiAnnotationManager: PointAnnotationManager?
    private let aqiService: AQIService
    
    var lastCameraCenter: CLLocationCoordinate2D
    var lastZoom: CGFloat
    
    init(mapView: MapView, lastCameraCenter: CLLocationCoordinate2D, lastZoom: CGFloat) {
        self.mapView = mapView
        self.lastCameraCenter = lastCameraCenter
        self.lastZoom = lastZoom
        
        self.aqiService = AQIService()
        
        updateAQIData()
        setupCameraListener()
    }
    
    func updateMapCameraCenter(coordinate: CLLocationCoordinate2D, zoom: CGFloat) {
        self.lastCameraCenter = coordinate
        self.lastZoom = zoom
        
        updateAQIData()
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
            
            updateMapCameraCenter(coordinate: center, zoom: zoom)
        }
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
