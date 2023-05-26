//
//  WelcomeViewController.swift
//  poke-test
//
//  Created by Samantha Cruz on 25/5/23.
//

import Combine
import UIKit

class WelcomeViewController: UIViewController {
    private var subscription: AnyCancellable?
    private var viewModel: WelcomeViewModelRepresentable
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 160, height: 160))
        imageView.image = #imageLiteral(resourceName: "pokeIcon")
        return imageView
    }()
    
    init(viewModel: WelcomeViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            self.animate()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setUI() {
        navigationController?.isNavigationBarHidden = true
        view.addSubview(imageView)
        imageView.center = view.center
    }
    
    private func animate() {
        UIView.animate(withDuration: 1, animations: {
            let size = self.view.frame.size.width * 3
            let diffX = size - self.view.frame.size.width
            let diffY = self.view.frame.size.height - size
            
            self.imageView.frame = CGRect(x: -(diffX/2), y: diffY/2, width: size, height: size)
            
        })
        
        UIView.animate(withDuration: 1.5, animations: {
            self.imageView.alpha = 0
        }, completion: { done in
            if done {
                self.viewModel.goToPokemon()
            }
        })
    }
}
