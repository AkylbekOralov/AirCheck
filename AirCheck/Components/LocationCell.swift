//
//  LocationCell.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 14.04.2025.
//

import UIKit
import SnapKit

class LocationCell: UITableViewCell {
    static let identifier = "LocationCell"
    
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let distanceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        nameLabel.font = .boldSystemFont(ofSize: 16)
        
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 0
        
        distanceLabel.font = .systemFont(ofSize: 14)
        distanceLabel.textColor = .blue

        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(distanceLabel)
    }

    private func setupConstraints() {
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        distanceLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualToSuperview().inset(10)
        }
    }

    func configure(with model: LocationModel) {
        nameLabel.text = model.name
        
        if let desc = model.description, !desc.isEmpty {
            descriptionLabel.isHidden = false
            descriptionLabel.text = desc
        } else {
            descriptionLabel.isHidden = true
            descriptionLabel.text = nil
        }

        if let distance = model.distance {
            distanceLabel.isHidden = false
            distanceLabel.text = String(format: "Distance: %.2f km", distance)
        } else {
            distanceLabel.isHidden = true
            distanceLabel.text = nil
        }
    }
}
