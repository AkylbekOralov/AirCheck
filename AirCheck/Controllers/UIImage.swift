//
//  UIImage.swift
//  AirCheck
//
//  Created by Akylbek Oralov on 30.03.2025.
//

import UIKit

extension UIImage {
    static func circleImage(color: UIColor, diameter: CGFloat = 30) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return renderer.image { ctx in
            let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
            ctx.cgContext.setFillColor(color.cgColor)
            ctx.cgContext.fillEllipse(in: rect)
        }
    }
}
