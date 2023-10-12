//
//  UIWindow.swift
//  poke-test
//
//  Created by Samantha Cruz on 12/10/23.
//

import UIKit

extension UIWindow {
    public func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = rootViewController {
            return UIWindow.getVisibleViewController(from: rootViewController)
        }
        return nil
    }
    
    public class func getVisibleViewController(from viewController: UIViewController) -> UIViewController {
        
        if viewController.isKind(of: UINavigationController.self),
           let navigationController = viewController as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return getVisibleViewController(from: visibleViewController)
            
        } else if viewController.isKind(of: UITabBarController.self),
                  let tabBarController = viewController as? UITabBarController,
                  let selectedViewController = tabBarController.selectedViewController {
            return getVisibleViewController(from: selectedViewController)
            
        } else {
            if let presentedViewController = viewController.presentedViewController,
               let presentedViewController = presentedViewController.presentedViewController {
                return getVisibleViewController(from: presentedViewController)
            } else {
                return viewController
            }
        }
    }
}
