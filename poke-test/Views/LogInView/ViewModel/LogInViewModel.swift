//
//  LogInViewModel.swift
//  poke-test
//
//  Created by Samantha Cruz on 26/5/23.
//

import GoogleSignIn
import Firebase
import UIKit

protocol LogInViewModelDelegate {
    func success()
    func error(_ errorMessage: String)
}

protocol LogInViewModelRepresentable {
    var delegate: LogInViewModelDelegate? { get set }
    func googleSignIn(_ viewController: UIViewController)
}

final class LogInViewModel<R: AppRouter> {
    var router: R?
    var delegate: LogInViewModelDelegate?

    private func successSignIn(email: String, provider: Provider) {
        self.delegate?.success()
        UserDefaultsManager.shared.provider = provider.rawValue
        self.router?.process(route: .showHome)
    }
}

extension LogInViewModel: LogInViewModelRepresentable {
    func googleSignIn(_ viewController: UIViewController) {
        
        GIDSignIn.sharedInstance.hasPreviousSignIn()
        GIDSignIn.sharedInstance.signOut()
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [unowned self] signInResult, error in
            if let _ = error {
                delegate?.error("")
                return
            }
            
            guard let authentication = signInResult?.user,
                  let idToken = authentication.idToken else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: authentication.accessToken.tokenString)
            
            
            Auth.auth().signIn(with: credential) { [weak self] result, error in
                guard let self = self,
                      let email = result?.user.email else {
                    self?.delegate?.error("Invalid credentials")
                    return
                }
                
                if let error = error {
                    self.delegate?.error(error.localizedDescription)
                } else {
                    self.successSignIn(email: email, provider: .google)
                }
            }
        }
    }
}

