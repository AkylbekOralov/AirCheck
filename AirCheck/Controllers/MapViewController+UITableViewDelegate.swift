//
//  MapViewController+UITableViewDelegate.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 21.04.2025.
//

import UIKit

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedSearchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.identifier, for: indexPath) as? LocationCell else {
            return UITableViewCell()
        }
        cell.configure(with: displayedSearchResults[indexPath.row])
        return cell
    }
    
    func tableView(_: UITableView, didSelectRowAt: IndexPath) {
        tableView.isHidden = true
        uiSearchBar.resignFirstResponder()
        uiSearchBar.setShowsCancelButton(false, animated: true)
        uiSearchBar.searchTextField.text = ""
        
        moveCamera(to: displayedSearchResults[didSelectRowAt.row].coordinate, zoom: 11, updateAnnotations: true)
    }
}
