//
//  MapViewController+UISearchBarDelegate.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 21.04.2025.
//
import UIKit

extension MapViewController: UISearchBarDelegate {
    func searchBar(_: UISearchBar, textDidChange: String) {
        searchDebounceTimer?.invalidate()
        
        if textDidChange.isEmpty {
            displayedSearchResults = KazakhstanCities.cities
            tableView.reloadData()
        } else if textDidChange.count >= 3 {
            searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                self.fetchSearchResults(for: textDidChange) { locations in
                    self.displayedSearchResults = locations
                    self.tableView.reloadData()
                }
            }
        } else {
            displayedSearchResults = []
            tableView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_: UISearchBar) {
        hidePopup()
        uiSearchBar.setShowsCancelButton(true, animated: true)
        displayedSearchResults = KazakhstanCities.cities
        tableView.reloadData()
        tableView.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_: UISearchBar) {
        uiSearchBar.text = ""
        uiSearchBar.resignFirstResponder()
        uiSearchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarTextDidEndEditing(_: UISearchBar) {
        tableView.isHidden = true
    }
}
