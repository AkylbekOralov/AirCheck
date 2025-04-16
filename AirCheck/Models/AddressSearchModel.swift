//
//  AddressSearchResultModel.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 16.04.2025.
//

import Foundation
import CoreLocation

struct AddressSearchModel: Decodable {
    let placeID: Int
    let lat: String
    let lon: String
    let fullAddress: String
    let name: String?

    enum CodingKeys: String, CodingKey {
        case placeID = "place_id"
        case lat, lon
        case fullAddress = "display_name"
        case name
    }
}

extension AddressSearchModel {
    func toLocationModel() -> LocationModel? {
        guard let latitude = Double(lat),
              let longitude = Double(lon) else {
            return nil
        }

        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let title = name ?? "Без названия"
        let description = fullAddress

        return LocationModel(name: title, coordinate: coordinate, description: description)
    }
}
