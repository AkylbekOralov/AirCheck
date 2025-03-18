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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView = MapView(frame: view.bounds)
        let cameraOptions = CameraOptions(center:
                                            CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0),
                                          zoom: 2, bearing: 0, pitch: 0)
        mapView.mapboxMap.setCamera(to: cameraOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(mapView)
    }
    
    
}

