//
//  MapViewController+MapManagerDelegate.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 21.04.2025.
//

import UIKit
import MapboxMaps
import CoreLocation

extension MapViewController: MapManagerDelegate {
    func moveCamera(to coordinate: CLLocationCoordinate2D, zoom: CGFloat, updateAnnotations: Bool) {
        let currentCenter = mapView.cameraState.center
        let currentLocation = CLLocation(latitude: currentCenter.latitude, longitude: currentCenter.longitude)
        let destinationLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let distance = currentLocation.distance(from: destinationLocation) / 1000
        
        var duration: TimeInterval
        
        switch true {
        case distance > 2000:
            duration = 4
        case distance > 500:
            duration = 3
        case distance > 300:
            duration = 2.5
        case distance > 150:
            duration = 2
        case distance > 75:
            duration = 1.2
        default:
            duration = 0.6
        }
        
        mapView.camera.fly(
            to: CameraOptions(center: coordinate, zoom: zoom),
            duration: duration
        ) { [weak self] _ in
            self?.mapManager.updateMapCameraCenter(coordinate: coordinate, zoom: zoom, updateAnnotations: updateAnnotations)
        }
    }
    
    func showPopup(aqiNumber: Int, at coordinate: CLLocationCoordinate2D, animated: Bool) {
        aqiPopupView.update(withAQI: aqiNumber)
        lastPopupCoordinate = coordinate
        
        if animated {
            self.aqiPopupView.isHidden = false
            aqiPopupView.transform = CGAffineTransform(translationX: 0, y: 150)
            aqiPopupView.isHidden = false
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.aqiPopupView.transform = .identity // Slide into place
            }, completion: nil)
        }
        
        isPopupVisible = true
    }
    
    func hidePopup() {
        guard isPopupVisible else { return }
        lastPopupCoordinate = nil
        mapManager.selectedAnnotationView?.isSelected = false
        mapManager.selectedAnnotationView = nil
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: {
            self.aqiPopupView.transform = CGAffineTransform(translationX: 0, y: 150)
        }) { _ in
            self.aqiPopupView.isHidden = true
            self.aqiPopupView.transform = .identity
            self.isPopupVisible = false
        }
    }
}
