//
//  SidebarViewContainer.swift
//  poke-test
//
//  Created by Samantha Cruz on 12/10/23.
//

import UIKit

final class SidebarViewContainer: UIView {
    
    private var didLayoutSubviews: Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !didLayoutSubviews {
            didLayoutSubviews = true
            
            if willRoundCorners, let corners = cornersToRound {
                roundCorners(corners: corners, radius: radius)
            }
        }
    }
    
    private var willRoundCorners: Bool = false
    private var cornersToRound: UIRectCorner?
    private var radius: CGFloat = 0
    
    public func prepareToRound(corners: UIRectCorner, withRadius radius: CGFloat) {
        if !didLayoutSubviews {
            willRoundCorners = true
            cornersToRound = corners
            self.radius = radius
        } else {
            roundCorners(corners: corners, radius: radius)
        }
    }
}


