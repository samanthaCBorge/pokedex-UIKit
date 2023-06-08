//
//  UIView.swift
//  poke-test
//
//  Created by Samantha Cruz on 8/6/23.
//

import UIKit

extension UIView {
    
    func setGradientBackground(colors: [UIColor]) -> Void {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
              gradientLayer.locations = [ 0.0, 1.0]
        gradientLayer.frame = self.bounds

        self.layer.insertSublayer(layer, at: 0)
    }
    
    func applyGradient(colours: [UIColor]) -> Void {
     let gradient: CAGradientLayer = CAGradientLayer()
     gradient.frame = self.bounds
     gradient.colors = colours.map { $0.cgColor }
     gradient.startPoint = CGPoint(x : 0, y : 1)
     gradient.endPoint = CGPoint(x : 1, y: 0)
    gradient.locations = [0,0.5,1]
     self.layer.insertSublayer(gradient, at: 0)
     }
}
