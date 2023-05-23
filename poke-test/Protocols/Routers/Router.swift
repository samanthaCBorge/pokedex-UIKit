//
//  Router.swift
//  poke-test
//
//  Created by Samantha Cruz on 28/2/23.
//

import UIKit

protocol Router: AnyObject {
    associatedtype Route
    var navigationController: UINavigationController { get set }
    func exit()
    func process(route: Route)
}

protocol AppRouter: Router where Route == AppTransition { }
