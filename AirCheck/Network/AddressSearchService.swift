//
//  AddressSearchService.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 16.04.2025.
//

import Alamofire

class AddressSearchService {
    
    static let shared = AddressSearchService()
    private let baseURL = "https://nominatim.openstreetmap.org/search"
    
    private init() {}
    
    func search(query: String, completion: @escaping (Result<[AddressSearchModel], Error>) -> Void) {
        let parameters: Parameters = [
            "q": query,
            "format": "json",
            "accept-language": "ru",
            "countrycodes": "kz"
        ]
        
        AF.request(baseURL, parameters: parameters)
            .validate()
            .responseDecodable(of: [AddressSearchModel].self) { response in
                switch response.result {
                case .success(let results):
                    completion(.success(results))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
