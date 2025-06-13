//
//  TimelineProvider.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 13.06.2025.
//

import WidgetKit
import Alamofire

struct Provider: TimelineProvider {
    let nameDictionary = NameDictionary()
    
    func placeholder(in context: Context) -> AQIEntry {
        AQIEntry(date: Date(), city: "Загрузка...", country: "", flag: "", aqi: 0)
        }
    
    func getSnapshot(in context: Context, completion: @escaping (AQIEntry) -> Void) {
            fetchAQIData { entry in
                completion(entry)
            }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AQIEntry>) -> Void) {
            fetchAQIData { entry in
                let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            }
    }
    
    private func fetchAQIData(completion: @escaping (AQIEntry) -> Void) {
            let defaults = UserDefaults(suiteName: "group.com.oralov.aircheck")
            let lat = defaults?.double(forKey: "latitude") ?? 0.0
            let lon = defaults?.double(forKey: "longitude") ?? 0.0
            let apiKey = "9ab32350-06d7-49db-800c-eb93f7ced6d8"

            let url = "https://api.airvisual.com/v2/nearest_city?lat=\(lat)&lon=\(lon)&key=\(apiKey)"
            
            AF.request(url).responseDecodable(of: AQIResponse.self) { response in
                switch response.result {
                case .success(let aqi):
                    let entry = AQIEntry(
                        date: Date(),
                        city: nameDictionary.cityTranslations[aqi.data.city] ?? aqi.data.city,
                        country: nameDictionary.countryTranslations[aqi.data.country] ?? aqi.data.country,
                        flag: nameDictionary.countryFlags[aqi.data.country] ?? "",
                        aqi: aqi.data.current.pollution.aqius
                    )
                    completion(entry)
                case .failure(let error):
                    print("AQI fetch failed: \(error)")
                    let fallback = AQIEntry(date: Date(), city: "Ошибка", country: "", flag: "", aqi: 0)
                    completion(fallback)
                }
            }
        }
}
