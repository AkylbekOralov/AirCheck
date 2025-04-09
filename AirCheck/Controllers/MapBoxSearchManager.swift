//
//  MapBoxSearchManager.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 09.04.2025.
//

import MapboxSearch
import Foundation

class MapBoxSearchManager {
    let placeAutocomplete = PlaceAutocomplete(accessToken: "pk.eyJ1Ijoib3JhbG92diIsImEiOiJjbTgxc3RvdmYxNGlkMnJzNWE3N3ZueWx0In0.VhEy-n9iWEEDKZ2fT_1ZKg")
    let query = "Starbucks"
    
    init() {
        
    }
    
    func makeSearchRequest(for query: String, completion: @escaping ([CityModel]) -> Void) {
        placeAutocomplete.suggestions(for: query) { result in
            switch result {
            case .success(let suggestions):
                print(suggestions)
                let searchResults = self.processSuggestions(suggestions: suggestions)
                completion(searchResults)
            case .failure(let error):
                debugPrint(error)
                completion([])
            }
        }
    }
    
    func processSuggestions(suggestions: [PlaceAutocomplete.Suggestion]) -> [CityModel] {
        return suggestions.compactMap { suggestion in
            guard let description = suggestion.description,
                  let coordinate = suggestion.coordinate else {
                return nil
            }
            
            return CityModel(cityName: description, location: coordinate)
        }
    }
    
    
}
