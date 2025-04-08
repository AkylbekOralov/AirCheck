//
//  MapViewController.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 18.03.2025.
//

import UIKit
import SnapKit
import MapboxMaps

class MapViewController: UIViewController {
    var mapView: MapView!
    private var mapManager: MapManager!
    
    let citiesList = ["Almaty", "Astana", "Shymkent", "Karaganda", "Aktobe", "Pavlodar", "Taraz", "Oskemen", "Semey", "Kostanay"]
    var displayedSearchResults: [String] = []
    
    private lazy var trackingButton = UIButton(frame: .zero)
    let uiSearchBar: UISearchBar = {
        let uiSearchBar = UISearchBar()
        uiSearchBar.placeholder = "Search city"
        uiSearchBar.searchBarStyle = .default
        uiSearchBar.barStyle = .default
        return uiSearchBar
    }()
    let tableView = UITableView()
    
    let aqiPopupView = AQIPopUpView()
    
    let initialCameraCoordinate = CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
    let initialZoom = CGFloat(10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        mapManager = MapManager(mapView: mapView, lastCameraCenter: initialCameraCoordinate, lastZoom: initialZoom)
        centerMapOnUserLocation()
        
        uiSearchBar.delegate = self
        view.addSubview(uiSearchBar)
        uiSearchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }
        
        tableView.isHidden = true
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.snp.makeConstraints { make in
            make.top.equalTo(uiSearchBar.snp.bottom)
            make.leading.trailing.equalTo(uiSearchBar)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        view.addSubview(aqiPopupView)
        aqiPopupView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
            make.height.equalTo(100)
        }
        
        setupTrackingButton()
        
        
    }
}

extension MapViewController: UISearchBarDelegate {
    func searchBar(_: UISearchBar, textDidChange: String) {
        print("text changed: \(textDidChange)")
    }
    
    func searchBarTextDidBeginEditing(_: UISearchBar) {
        uiSearchBar.setShowsCancelButton(true, animated: true)
        displayedSearchResults = citiesList
        tableView.reloadData()
        tableView.isHidden = false
        print("begins editing ...")
    }
    
    func searchBarCancelButtonClicked(_: UISearchBar) {
        uiSearchBar.text = ""
        uiSearchBar.resignFirstResponder()
        uiSearchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarTextDidEndEditing(_: UISearchBar) {
        tableView.isHidden = true
        displayedSearchResults = []
        tableView.reloadData()
        print("stops editing ...")
    }
}

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedSearchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = displayedSearchResults[indexPath.row]
        return cell
    }
}

private extension MapViewController {
    
    func setupMapView() {
        let startCameraCenter = CameraOptions(center: initialCameraCoordinate, zoom: initialZoom)
        let initOptions = MapInitOptions(cameraOptions: startCameraCenter, styleURI: .standard)
        
        self.mapView = MapView(frame: view.bounds, mapInitOptions: initOptions)
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mapView.location.options.puckType = .puck2D()
        
        view.addSubview(mapView)
        
        // Camera Bounds
        let bounds = CameraBoundsOptions(maxZoom: 14.0, minZoom: 3.0)
        try? self.mapView.mapboxMap.setCameraBounds(with: bounds)
    }
    
    @objc func centerMapOnUserLocation() {
        if let location = mapView.location.latestLocation {
            moveCamera(to: location.coordinate, zoom: 12)
            self.mapManager.updateMapCameraCenter(coordinate: location.coordinate, zoom: 12)
        } else {
            _ = mapView.location.onLocationChange.observeNext { [weak self] locations in
                guard let coordinate = locations.last?.coordinate else { return }
                self?.moveCamera(to: coordinate, zoom: 12)
                self?.mapManager.updateMapCameraCenter(coordinate: coordinate, zoom: 12)
            }
        }
    }
    
    func moveCamera(to coordinate: CLLocationCoordinate2D, zoom: CGFloat) {
        mapView.camera.ease(
            to: CameraOptions(center: coordinate, zoom: zoom),
            duration: 1.2
        ) { [weak self] _ in
            self?.mapManager.updateMapCameraCenter(coordinate: coordinate, zoom: zoom)
        }
    }
    
    // MARK: Location Button
    func setupTrackingButton() {
        trackingButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        trackingButton.tintColor = .systemBlue
        trackingButton.backgroundColor = UIColor(white: 0.97, alpha: 1)
        trackingButton.layer.cornerRadius = 22
        trackingButton.layer.shadowColor = UIColor.black.cgColor
        trackingButton.layer.shadowOpacity = 0.3
        trackingButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        trackingButton.layer.shadowRadius = 2
        
        trackingButton.addTarget(self, action: #selector(centerMapOnUserLocation), for: .touchUpInside)
        
        view.addSubview(trackingButton)
        
        trackingButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(aqiPopupView.snp.top).offset(-16)
            make.width.height.equalTo(44)
        }
    }
}
