//
//  UIView.swift
//  poke-test
//
//  Created by Samantha Cruz on 8/6/23.
//

import UIKit

extension UIView {
    func applyGradient(colours: [UIColor]) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = CGPoint(x : 0, y : 1)
        gradient.endPoint = CGPoint(x : 1.2, y: 0)
        gradient.locations = [0,0.5,1]
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    public func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        if layer.mask != nil {
            layer.mask = nil
            superview?.layoutIfNeeded()
        }
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
