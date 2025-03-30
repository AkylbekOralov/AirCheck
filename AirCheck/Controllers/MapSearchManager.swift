//
//  MapSearchManager.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 30.03.2025.
//

import MapboxSearchUI
import MapboxSearch
import MapboxMaps
import UIKit

final class MapSearchManager: NSObject {
    private let mapView: MapView
    private let searchController = MapboxSearchController()
    private lazy var searchAnnotationsManager = mapView.annotations.makePointAnnotationManager()
    
    private weak var presentingViewController: UIViewController?
    
    init(mapView: MapView, presentingViewController: UIViewController) {
        self.mapView = mapView
        self.presentingViewController = presentingViewController
        super.init()
        
        searchController.delegate = self
    }
    
    func presentSearchUI() {
        let panelController = MapboxPanelController(rootViewController: searchController)
        presentingViewController?.addChild(panelController)
    }
    
    private func showAnnotations(results: [SearchResult], cameraShouldFollow: Bool = true) {
        searchAnnotationsManager.annotations = results.map { result in
            var annotation = PointAnnotation(coordinate: result.coordinate)
            annotation.image = .init(image: UIImage(named: "SearchPoint")!, name: "dest-pin")
            
            annotation.tapHandler = { [weak self] _ in
                self?.present(result: result)
                return true
            }
            return annotation
        }
        
        if cameraShouldFollow {
            moveCameraToAnnotations(searchAnnotationsManager.annotations)
        }
    }
    
    private func moveCameraToAnnotations(_ annotations: [PointAnnotation]) {
        guard !annotations.isEmpty else { return }

        if annotations.count == 1, let annotation = annotations.first {
            mapView.camera.fly(
                to: .init(center: annotation.point.coordinates, zoom: 14),
                duration: 0.3
            )
        } else {
            do {
                let cameraState = mapView.mapboxMap.cameraState
                let camera = try mapView.mapboxMap.camera(
                    for: annotations.map(\.point.coordinates),
                    camera: CameraOptions(cameraState: cameraState),
                    coordinatesPadding: UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24),
                    maxZoom: nil,
                    offset: nil
                )
                mapView.camera.fly(to: camera, duration: 0.3)
            } catch {
                print("❌ Camera error: \(error.localizedDescription)")
            }
        }
    }
    
    @discardableResult
    private func present(result: SearchResult) -> Bool {
        let detailVC = SearchResultViewController(result: result)
        presentingViewController?.present(detailVC, animated: true)
        return true
    }
}

extension MapSearchManager: SearchControllerDelegate {
    func searchResultSelected(_ searchResult: SearchResult) {
        showAnnotations(results: [searchResult])
    }

    func userFavoriteSelected(_ userFavorite: FavoriteRecord) {
        showAnnotations(results: [userFavorite])
    }

    func categorySearchResultsReceived(category: SearchCategory, results: [SearchResult]) {
        showAnnotations(results: results)
    }
}
