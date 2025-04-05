//
//  SearchBarView.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 05.04.2025.
//

import UIKit
import SnapKit

class SearchBarView: UIView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .gray
        return imageView
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search"
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 10
        clipsToBounds = false
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        
        addSubview(iconImageView)
        addSubview(textField)
    }
    
    private func setupConstraints() {
        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalTo(textField.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
}
