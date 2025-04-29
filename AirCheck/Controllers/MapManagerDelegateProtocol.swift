//
//  MapManagerDelegateProtocol.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 21.04.2025.
//

import Foundation
import CoreLocation

protocol MapManagerDelegate: AnyObject {
    func moveCamera(to coordinate: CLLocationCoordinate2D, zoom: CGFloat, updateAnnotations: Bool)
    func showPopup(aqiNumber: Int, at coordinate: CLLocationCoordinate2D, animated: Bool)
    func hidePopup()
}
