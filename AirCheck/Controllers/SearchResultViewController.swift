//
//  SearchResultViewController.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 28.03.2025.
//

import UIKit
import MapboxSearch

class SearchResultViewController: UIViewController {
    private let result: SearchResult

    init(result: SearchResult) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = result.name
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let addressLabel = UILabel()
        addressLabel.text = result.address?.formattedAddress(style: .medium) ?? "Адрес не найден"
        addressLabel.numberOfLines = 0
        addressLabel.translatesAutoresizingMaskIntoConstraints = false

        let favoriteButton = UIButton(type: .system)
        favoriteButton.setTitle("⭐ Добавить в избранное", for: .normal)
        favoriteButton.addTarget(self, action: #selector(addToFavorites), for: .touchUpInside)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel, favoriteButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    @objc func addToFavorites() {
        // Здесь ты можешь сохранить в UserDefaults, CoreData и т.д.
        print("Добавлено в избранное: \(result.name)")
        dismiss(animated: true)
    }
}
