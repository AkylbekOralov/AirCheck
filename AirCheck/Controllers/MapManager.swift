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
    weak var delegate: MapManagerDelegate?
    
    var lastCameraCenter: CLLocationCoordinate2D
    var lastZoom: CGFloat
    
    var selectedAnnotationView: MarkerView?
    
    private var aqiUpdateTimer: Timer?
    private var lastAQIFetchRegion: String?
    
    init(mapView: MapView, lastCameraCenter: CLLocationCoordinate2D, lastZoom: CGFloat) {
        self.mapView = mapView
        self.lastCameraCenter = lastCameraCenter
        self.lastZoom = lastZoom
        self.aqiService = AQIService()
        
        updateAQIData()
        setupCameraListener()
    }
    
    func updateMapCameraCenter(coordinate: CLLocationCoordinate2D, zoom: CGFloat, updateAnnotations: Bool = true) {
        self.lastCameraCenter = coordinate
        self.lastZoom = zoom
        
        if updateAnnotations {
            self.updateAQIData()
        }
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
        guard let (bbox, zoomLevel) = aqiService.getExpandedBoundingBox(from: mapView) else {
            return
        }
        
        if bbox == lastAQIFetchRegion {
            print("Skipping AQI fetch: bounding box unchanged")
            return
        }
        
        lastAQIFetchRegion = bbox
        
        aqiService.fetchAQIData(mapView: mapView) { [weak self] markers in
            guard let self, let markers else { return }
            DispatchQueue.main.async {
                self.addAQIMarkers(markers)
            }
        }
    }
    
    private func addAQIMarkers(_ markers: [AQIMarker]) {
        mapView.viewAnnotations.removeAll()
        self.selectedAnnotationView = nil
        
        for marker in markers {
            let coordinate = CLLocationCoordinate2D(
                latitude: marker.coordinates.latitude,
                longitude: marker.coordinates.longitude
            )
            
            let annotationView = MarkerView(number: marker.aqi, coordinate: coordinate)
            annotationView.isUserInteractionEnabled = true

            let tap = UITapGestureRecognizer(target: self, action: #selector(handleAnnotationTap(_:)))
            annotationView.addGestureRecognizer(tap)
            
            let options = ViewAnnotationOptions(
                geometry: Point(coordinate),
                allowOverlap: false,
                anchor: .center
            )
            try? mapView.viewAnnotations.add(annotationView, options: options)
        }
    }
    
    @objc func handleAnnotationTap(_ gesture: UITapGestureRecognizer) {
        guard let annotationView = gesture.view as? MarkerView else { return }
        var animation = true
        
        if let lastSelectedAnnotation = selectedAnnotationView {
            lastSelectedAnnotation.isSelected = false
            animation = false
        }
        
        selectedAnnotationView = annotationView
        selectedAnnotationView?.isSelected = true
        
        let number = annotationView.aqiNumber
        let coordinate = annotationView.coordinate
        
        delegate?.moveCamera(to: coordinate, zoom: mapView.mapboxMap.cameraState.zoom, updateAnnotations: false)
        delegate?.showPopup(aqiNumber: number, at: coordinate, animation: animation)
    }
}
