//
//  AQIService.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 23.03.2025.
//

import Foundation
import MapboxMaps
import Alamofire

class AQIService {
    func fetchAQIData(mapView: MapView, completion: @escaping ([AQIMarker]?) -> Void) {
        guard let (bbox, zoomLevel) = getExpandedBoundingBox(from: mapView) else {
            print("Failed to get expanded bounding box.")
            completion(nil)
            return
        }

        let url = "https://website-api.airvisual.com/v1/places/map/clusters"
        let parameters: Parameters = [
            "bbox": bbox,
            "zoomLevel": zoomLevel,
            "units.temperature": "celsius",
            "units.distance": "kilometer",
            "units.pressure": "millibar",
            "units.system": "metric",
            "AQI": "US",
            "language": "en"
        ]

        AF.request(url, parameters: parameters)
            .validate()
            .responseDecodable(of: AQIResponse.self) { response in
                switch response.result {
                case .success(let result):
                    completion(result.markers)
                case .failure(let error):
                    print("Failed to fetch AQI data: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        printVisibleRegionInfo(mapView: mapView)
    }
    
    func printVisibleRegionInfo(mapView: MapView) {
        guard let (bbox, zoomLevel) = getExpandedBoundingBox(from: mapView) else {
            print("Failed to get bounding box of the map view")
            return
        }

        let coords = bbox.split(separator: ",").map { Double($0) ?? 0 }
        let minLon = coords[0]
        let minLat = coords[1]
        let maxLon = coords[2]
        let maxLat = coords[3]

        print("Bounding Box:")
        print("  minLongitude (Left/West): \(minLon)")
        print("  maxLongitude (Right/East): \(maxLon)")
        print("  minLatitude  (Bottom/South): \(minLat)")
        print("  maxLatitude  (Top/North): \(maxLat)")
        print("Zoom Level: \(zoomLevel)")
    }

    private func getExpandedBoundingBox(from mapView: MapView) -> (String, Int)? {
        let cameraState = mapView.mapboxMap.cameraState
        let zoom = Int(cameraState.zoom)
        let center = cameraState.center

        guard let bounds = try? mapView.mapboxMap.coordinateBounds(for: CameraOptions(center: center, zoom: cameraState.zoom)) else {
            return nil
        }

        // Extra 5km padding to the bounds
        let latitudeDelta = 5.0 / 111.0
        let longitudeDelta = 5.0 / 85.0

        let minLat = bounds.southwest.latitude - latitudeDelta
        let minLon = bounds.southwest.longitude - longitudeDelta
        let maxLat = bounds.northeast.latitude + latitudeDelta
        let maxLon = bounds.northeast.longitude + longitudeDelta

        let bbox = "\(minLon),\(minLat),\(maxLon),\(maxLat)"
        return (bbox, zoom)
    }
}
