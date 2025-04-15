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
    
    private var selectedAnnotationView: MarkerView?
    
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
            
            if let delegate = self.delegate as? MapViewController,
               let lastCoord = delegate.lastPopupCoordinate {
                let movedDistance = CLLocation(latitude: center.latitude, longitude: center.longitude)
                    .distance(from: CLLocation(latitude: lastCoord.latitude, longitude: lastCoord.longitude))
                if movedDistance > 100 {
                    delegate.hidePopup()
                }
            }
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
            
            let annotation = ViewAnnotation(
                coordinate: coordinate,
                view: annotationView
            )
            mapView.viewAnnotations.add(annotation)
        }
    }
    
    @objc func handleAnnotationTap(_ gesture: UITapGestureRecognizer) {
        guard let annotationView = gesture.view as? MarkerView else { return }
        
        if let lastSelectedAnnotation = selectedAnnotationView {
            lastSelectedAnnotation.isSelected = false
        }
        
        selectedAnnotationView = annotationView
        selectedAnnotationView?.isSelected = true
        
        let number = annotationView.aqiNumber
        let coordinate = annotationView.coordinate
        
        delegate?.moveCamera(to: coordinate, zoom: mapView.mapboxMap.cameraState.zoom, updateAnnotations: false)
        delegate?.showPopup(aqiNumber: number, at: coordinate)
    }
}

protocol MapManagerDelegate: AnyObject {
    func moveCamera(to coordinate: CLLocationCoordinate2D, zoom: CGFloat, updateAnnotations: Bool)
    func showPopup(aqiNumber: Int, at coordinate: CLLocationCoordinate2D)
    func hidePopup()
}
