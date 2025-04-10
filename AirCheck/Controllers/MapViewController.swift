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
    
    var displayedSearchResults: [LocationModel] = []
    
    private lazy var userLocationButton = UIButton()
    private var uiSearchBar = UISearchBar()
    private var tableView = UITableView()
    let aqiPopupView = AQIPopUpView()
    private var isPopupVisible = false
    
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
        let currentCenter = mapView.cameraState.center
        let currentLocation = CLLocation(latitude: currentCenter.latitude, longitude: currentCenter.longitude)
        let destinationLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let distance = currentLocation.distance(from: destinationLocation) / 1000
        
        var duration: TimeInterval

        switch true {
        case distance > 500:
            duration = 4
        case distance > 300:
            duration = 3.5
        case distance > 150:
            duration = 2.5
        case distance > 75:
            duration = 1.2
        default:
            duration = 0.6
        }
        
        print("distance: \(distance)km")
        print("duration: \(duration)s")
        
        mapView.camera.fly(
            to: CameraOptions(center: coordinate, zoom: zoom),
            duration: duration
        ) { [weak self] _ in
            self?.mapManager.updateMapCameraCenter(coordinate: coordinate, zoom: zoom)
        }
    }
    
    func showPopup(aqiNumber: Int, at coordinate: CLLocationCoordinate2D) {
        aqiPopupView.update(withAQI: aqiNumber)
     
        aqiPopupView.alpha = 0
        aqiPopupView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.aqiPopupView.alpha = 1
        }
        
        isPopupVisible = true
    }
    
    func hidePopup() {
        guard isPopupVisible else { return }

        UIView.animate(withDuration: 0.3, animations: {
            self.aqiPopupView.alpha = 0
        }) { _ in
            self.aqiPopupView.isHidden = true
            self.isPopupVisible = false
        }
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
        let city = displayedSearchResults[indexPath.row]

        // Content Style
        var content = cell.defaultContentConfiguration()
        content.text = city.name
        content.textProperties.font = .systemFont(ofSize: 16, weight: .medium)
        content.textProperties.color = .label
        cell.contentConfiguration = content

        // Background Style
        cell.backgroundColor = .secondarySystemBackground

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = .zero
        cell.preservesSuperviewLayoutMargins = false
    }
    
    func tableView(_: UITableView, didSelectRowAt: IndexPath) {
        tableView.isHidden = true
        uiSearchBar.resignFirstResponder()
        uiSearchBar.setShowsCancelButton(false, animated: true)
        uiSearchBar.searchTextField.text = ""
        
        moveCamera(to: displayedSearchResults[didSelectRowAt.row].coordinate, zoom: 11)
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
        try! self.mapView.mapboxMap.localizeLabels(into: Locale(identifier: "ru"))
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
        uiSearchBar.searchBarStyle = .minimal
        uiSearchBar.delegate = self

        if let textField = uiSearchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.systemGray6
            textField.layer.cornerRadius = 10
            textField.clipsToBounds = true
            textField.textColor = .label
        }

        uiSearchBar.backgroundImage = UIImage()
        uiSearchBar.barTintColor = .clear
        uiSearchBar.backgroundColor = .clear

        view.addSubview(uiSearchBar)
        uiSearchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }
    }
    
    // MARK: TableView Setup
    func setupTableView() {
        tableView.isHidden = true
        tableView.layer.cornerRadius = 12
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .secondarySystemBackground

        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        tableView.snp.makeConstraints { make in
            make.top.equalTo(uiSearchBar.snp.bottom).offset(8)
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
        aqiPopupView.isHidden = true
        aqiPopupView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
            make.height.equalTo(100)
        }
    }
}
