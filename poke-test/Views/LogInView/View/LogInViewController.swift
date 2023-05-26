//
//  LogInViewController.swift
//  poke-test
//
//  Created by Samantha Cruz on 26/5/23.
//

import Combine
import GoogleSignIn
import UIKit

class LogInViewController: UIViewController {
    
    @IBOutlet private var logInLabel: UILabel!
    private var subscription: AnyCancellable?
    private var viewModel: LogInViewModelRepresentable
    
    init(viewModel: LogInViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setUI() {
        navigationController?.isNavigationBarHidden = true
        logInLabel.font = UIFont(name: "PokemonGB", size: 14) ?? UIFont.systemFont(ofSize: 18)
    }
    
    @IBAction func didTapGoogleButton(_ sender: Any) {
        viewModel.googleSignIn(self)
    }
    
}

