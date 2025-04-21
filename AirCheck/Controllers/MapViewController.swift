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
    private(set) var mapManager: MapManager!
    
    var displayedSearchResults: [LocationModel] = []
    
    private lazy var userLocationButton = UIButton()
    private(set) var uiSearchBar = UISearchBar()
    private(set) var tableView = UITableView()
    
    let aqiPopupView = AQIPopUpView()
    var isPopupVisible = false
    
    let initialCameraCoordinate = CLLocationCoordinate2D(latitude: 43.2380, longitude: 76.8829)
    let initialZoom = CGFloat(10)
    
    var lastPopupCoordinate: CLLocationCoordinate2D?
    var searchDebounceTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        mapManager = MapManager(mapView: mapView, lastCameraCenter: initialCameraCoordinate, lastZoom: initialZoom)
        mapManager.delegate = self
        
        setupSearchBar()
        setupAQIPopUpView()
        setupUserLocationButton()
        setupTableView()
        
        observePanGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        centerMapOnUserLocation()
    }
}

extension MapViewController {
    func fetchSearchResults(for query: String, completion: @escaping ([LocationModel]) -> Void) {
        AddressSearchService.shared.search(query: query) { result in
            switch result {
            case .success(let addresses):
                let locations: [LocationModel] = addresses.compactMap { $0.toLocationModel() }
                completion(locations)
            case .failure(let error):
                print("Search error: \(error.localizedDescription)")
                completion([])
            }
        }
    }
    
    private func observePanGesture() {
        mapView.gestures.panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            hidePopup()
        }
    }
    
    func setupMapView() {
        let startCameraCenter = CameraOptions(center: initialCameraCoordinate, zoom: initialZoom)
        var styleURI: StyleURI!
        
        if traitCollection.userInterfaceStyle == .dark {
            styleURI = StyleURI(rawValue: "mapbox://styles/oralovv/cm9jo2meh00s801s74yz75cbj")!
        } else {
            styleURI = StyleURI(rawValue: "mapbox://styles/oralovv/cm9h9putj00pf01s82y7d9zu0")!
        }
        let initOptions = MapInitOptions(
            cameraOptions: startCameraCenter,
            styleURI: styleURI
        )
        
        self.mapView = MapView(frame: view.bounds, mapInitOptions: initOptions)
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mapView.location.options.puckType = .puck2D()
        view.addSubview(mapView)
        
        let bounds = CameraBoundsOptions(maxZoom: 14.0, minZoom: 6.0)
        try? self.mapView.mapboxMap.setCameraBounds(with: bounds)
    }
    
    @objc func centerMapOnUserLocation() {
        hidePopup()
        if let location = mapView.location.latestLocation {
            moveCamera(to: location.coordinate, zoom: 12, updateAnnotations: true)
        } else {
            _ = mapView.location.onLocationChange.observeNext { [weak self] locations in
                guard let coordinate = locations.last?.coordinate else { return }
                self?.moveCamera(to: coordinate, zoom: 12, updateAnnotations: true)
            }
        }
    }
    
    // MARK: SearchBar Setup
    func setupSearchBar() {
        uiSearchBar.placeholder = "Введите адрес или город"
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
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: LocationCell.identifier)
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(uiSearchBar.snp.bottom).offset(8)
            make.leading.trailing.equalTo(uiSearchBar)
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    
    // MARK: User Location Button Setup
    func setupUserLocationButton() {
        userLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        userLocationButton.tintColor = .systemBlue
        userLocationButton.backgroundColor = .systemBackground
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
