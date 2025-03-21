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
    private var locationTrackingCancellation: AnyCancelable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 37.26301831966747, longitude: -121.97647612483807), zoom: 10)
        let options = MapInitOptions(cameraOptions: cameraOptions, styleURI: .standard)
        
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
        setupLocationButton()
        
        let configuration = Puck2DConfiguration.makeDefault(showBearing: true)
        mapView.location.options.puckType = .puck2D(configuration)
        
        mapView.gestures.delegate = self
        
        // Update the camera's centerCoordinate when a locationUpdate is received.
        startTracking()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupLocationButton() {
        trackingButton.addTarget(self, action: #selector(switchTracking), for: .touchUpInside)

        trackingButton.setImage(UIImage(systemName: "location.fill"), for: .normal)

        let buttonWidth = 44.0
        trackingButton.translatesAutoresizingMaskIntoConstraints = false
        trackingButton.backgroundColor = UIColor(white: 0.97, alpha: 1)
        trackingButton.layer.cornerRadius = buttonWidth/2
        trackingButton.layer.shadowOffset = CGSize(width: -1, height: 1)
        trackingButton.layer.shadowColor = UIColor.black.cgColor
        trackingButton.layer.shadowOpacity = 0.5
        view.addSubview(trackingButton)

        NSLayoutConstraint.activate([
            trackingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            trackingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -48),
            trackingButton.widthAnchor.constraint(equalTo: trackingButton.heightAnchor),
            trackingButton.widthAnchor.constraint(equalToConstant: buttonWidth)
        ])
    }
    
    @objc func switchTracking() {
        let isTrackingNow = locationTrackingCancellation != nil
        if isTrackingNow {
            stopTracking()
        } else {
            startTracking()
        }
    }
    
    private func startTracking() {
        locationTrackingCancellation = mapView.location.onLocationChange.observe { [weak mapView] newLocation in
            guard let location = newLocation.last, let mapView else { return }
            mapView.camera.ease(
                to: CameraOptions(center: location.coordinate, zoom: 15),
                duration: 1.3)
        }

        trackingButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
    }

    func stopTracking() {
        trackingButton.setImage(UIImage(systemName: "location"), for: .normal)
        locationTrackingCancellation = nil
    }
    
}

extension ViewController: GestureManagerDelegate {
    public func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didBegin gestureType: MapboxMaps.GestureType) {
        stopTracking()
    }

    public func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEnd gestureType: MapboxMaps.GestureType, willAnimate: Bool) {}

    public func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEndAnimatingFor gestureType: MapboxMaps.GestureType) {}
}

