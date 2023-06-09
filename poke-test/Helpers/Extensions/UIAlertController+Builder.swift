//
//  UIAlertController+Builder.swift
//  poke-test
//
//  Created by Samantha Cruz on 22/5/23.
//

import UIKit

extension UIAlertController {
    
    final class Builder {
        private var title: String?
        private var message: String?
        private var actions: [UIAlertAction] = []
        private var alertStyle: UIAlertController.Style = .alert
        private var showTextField = false
        
        public var textFields: [UITextField]?
        
        @discardableResult func withTitle(_ title: String?) -> Builder {
            self.title = title
            return self
        }
        
        @discardableResult func withMessage(_ message: String?) -> Builder {
            self.message = message
            return self
        }
        
        @discardableResult func withButton(style: UIAlertAction.Style = .default,
                                           title: String,
                                           callback: ((Builder) -> Void)? = nil) -> Builder {
            
            let cancelAction = UIAlertAction(title: title,
                                             style: style,
                                             handler: { _ in callback?(self) })
            
            actions.append(cancelAction)
            return self
        }
        
        @discardableResult func withAlertStyle(_ style: UIAlertController.Style) -> Builder {
            self.alertStyle = style
            return self
        }
        
        @discardableResult func withTextField(_ showTextField: Bool) -> Builder {
            self.showTextField = showTextField
            return self
        }
        
        func present(in viewController: UIViewController) {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self, viewController.isViewLoaded, viewController.view.window != nil else { return }
                let alert = UIAlertController(title: self.title, message: self.message, preferredStyle: self.alertStyle)
                if self.showTextField {
                    alert.addTextField()
                    self.textFields = alert.textFields
                }
                
                self.actions.forEach { alert.addAction($0) }
                viewController.present(alert, animated: true)
            }
        }
    }
}

extension UIViewController {
    func presentAlert(with error: Error) {
        UIAlertController
            .Builder()
            .withTitle("Pokedex")
            .withMessage(error.localizedDescription)
            .withButton(title: "OK")
            .present(in: self)
    }
    
    func presentAlert(with message: String) {
        UIAlertController
            .Builder()
            .withTitle("Pokedex")
            .withMessage(message)
            .withButton(title: "OK")
            .present(in: self)
    }
}
