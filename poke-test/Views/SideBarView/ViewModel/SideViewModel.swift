//
//  SideViewModel.swift
//  poke-test
//
//  Created by Samantha Cruz on 12/10/23.
//

import Foundation

public enum MenuOption {
    case home
    case teams
    case logOut
}

final class SideMenuViewModel {
    
    lazy var menuOptions = [
        Option(id: 0, name: "Home", icon: "house.circle.fill", type: .home),
        Option(id: 1, name: "Teams", icon: "tray.circle.fill", type: .teams),
        Option(id: 2, name: "Log Out", icon: "rectangle.portrait.and.arrow.forward.fill", type: .logOut)
    ]
}

