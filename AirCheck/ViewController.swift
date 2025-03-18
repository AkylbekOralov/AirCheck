//
//  ViewController.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 18.03.2025.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        
        let text = UILabel()
        text.text = "Hello, World!"
        view.addSubview(text)
        
        text.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }


}

