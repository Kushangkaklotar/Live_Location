//
//  UIVIew-Extension.swift
//  Notes
//
//  Created by Kushang  on 06/10/24.
//

import Foundation
import UIKit

extension UIView {
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
        clipsToBounds = false
    }
    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = bounds

       layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - Loader
    func loader(){
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1650000066, green: 0.1920000017, blue: 0.1959999949, alpha: 1)
        view.addSubview(view)
    }
}
