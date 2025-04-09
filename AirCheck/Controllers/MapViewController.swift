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
    private var mapBoxSearchManager = MapBoxSearchManager()

    var displayedSearchResults: [CityModel] = []
    
    private lazy var userLocationButton = UIButton()
    private var uiSearchBar = UISearchBar()
    private var tableView = UITableView()
    
    let aqiPopupView = AQIPopUpView()
    
    let initialCameraCoordinate = CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
    let initialZoom = CGFloat(10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        mapManager = MapManager(mapView: mapView, lastCameraCenter: initialCameraCoordinate, lastZoom: initialZoom)
        mapManager.delegate = self
        centerMapOnUserLocation()
        
        setupSearchBar()
        setupTableView()
        setupAQIPopUpView()
        setupUserLocationButton()
    }
}

// Delegate to handle taps on annotations
extension MapViewController: MapManagerDelegate {
    func moveCamera(to coordinate: CLLocationCoordinate2D, zoom: CGFloat) {
        mapView.camera.fly(
            to: CameraOptions(center: coordinate, zoom: zoom),
            duration: 3
        ) { [weak self] _ in
            self?.mapManager.updateMapCameraCenter(coordinate: coordinate, zoom: zoom)
        }
    }

    func showPopup(text: String, at coordinate: CLLocationCoordinate2D) {
        // Optional: You can implement showing AQIPopUpView with some updated content
        print("Show popup with text: \(text) at coordinate: \(coordinate)")
    }
}

// MARK: UISearchBarDelegate
extension MapViewController: UISearchBarDelegate {
    func searchBar(_: UISearchBar, textDidChange: String) {
        print("SEARCHBAR: text changed: \(textDidChange)")
        
        mapBoxSearchManager.makeSearchRequest(for: textDidChange) { cityModels in
            self.displayedSearchResults = cityModels
            self.tableView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_: UISearchBar) {
        uiSearchBar.setShowsCancelButton(true, animated: true)
        displayedSearchResults = KazakhstanCities.cities
        tableView.reloadData()
        tableView.isHidden = false
        print("SEARCHBAR: begins editing ...")
    }
    
    func searchBarCancelButtonClicked(_: UISearchBar) {
        uiSearchBar.text = ""
        uiSearchBar.resignFirstResponder()
        uiSearchBar.setShowsCancelButton(false, animated: true)
        print("SEARCHBAR: cancel button clicked")
    }
    
    func searchBarTextDidEndEditing(_: UISearchBar) {
        tableView.isHidden = true
        print("SEARCHBAR: stops editing ...")
    }
}

// MARK: UITableViewDelegate
extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedSearchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = displayedSearchResults[indexPath.row].cityName
        return cell
    }
    
    func tableView(_: UITableView, didSelectRowAt: IndexPath) {
        tableView.isHidden = true
        uiSearchBar.resignFirstResponder()
        uiSearchBar.setShowsCancelButton(false, animated: true)
        uiSearchBar.searchTextField.text = ""
        
        moveCamera(to: displayedSearchResults[didSelectRowAt.row].location, zoom: 11)
        print("TABLEVIEW: row #\(didSelectRowAt.row) selected")
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
    
    // MARK: SearchBar Setup
    func setupSearchBar() {
        uiSearchBar.placeholder = "Search city"
        uiSearchBar.searchBarStyle = .default
        uiSearchBar.barStyle = .default
        
        uiSearchBar.delegate = self
        view.addSubview(uiSearchBar)
        uiSearchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }
    }
    
    // MARK: TableView Setup
    func setupTableView() {
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
    }
    
    // MARK: User Location Button Setup
    func setupUserLocationButton() {
        userLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        userLocationButton.tintColor = .systemBlue
        userLocationButton.backgroundColor = UIColor(white: 0.97, alpha: 1)
        userLocationButton.layer.cornerRadius = 22
        userLocationButton.layer.shadowColor = UIColor.black.cgColor
        userLocationButton.layer.shadowOpacity = 0.3
        userLocationButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        userLocationButton.layer.shadowRadius = 2
        
        userLocationButton.addTarget(self, action: #selector(centerMapOnUserLocation), for: .touchUpInside)
        
        view.addSubview(userLocationButton)
        
        userLocationButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(aqiPopupView.snp.top).offset(-16)
            make.width.height.equalTo(44)
        }
    }
    
    // MARK: AQI Pop Up View Setup
    func setupAQIPopUpView() {
        view.addSubview(aqiPopupView)
        aqiPopupView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
            make.height.equalTo(100)
        }
    }
}
