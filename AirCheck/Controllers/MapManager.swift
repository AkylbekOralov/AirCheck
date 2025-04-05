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
            
            // 3.3 km and 2.4 km change
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
        mapView.viewAnnotations.removeAll()
        
        for marker in markers {
            let annotation = ViewAnnotation(
                coordinate: CLLocationCoordinate2D(
                    latitude: marker.coordinates.latitude,
                    longitude: marker.coordinates.longitude
                ),
                view: MarkerView(number: marker.aqi)
            )
            mapView.viewAnnotations.add(annotation)
        }
    }
}
