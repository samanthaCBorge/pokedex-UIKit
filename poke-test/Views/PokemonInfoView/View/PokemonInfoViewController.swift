//
//  PokemonInfoViewController.swift
//  poke-test
//
//  Created by Samantha Cruz on 30/5/23.
//

import UIKit
import Combine

final class PokemonInfoViewController: UIViewController {
    
    @IBOutlet private var stackView: UIStackView!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var nameLabel: UILabel!
    
    @IBOutlet private var typeLabel: UILabel!
    
    @IBOutlet private var height: UILabel!
    
    @IBOutlet private var weight: UILabel!
    
    @IBOutlet private var scrollView: UIScrollView!
    
    @IBOutlet private var backgroundView: UIView!
    
    @IBOutlet weak var typeView: UIView!
    private var subscription: AnyCancellable?
    private let viewModel: PokemonInfoViewModelRepresentable
    
    init(viewModel: PokemonInfoViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bindUI()
        
        let appearance = UINavigationBarAppearance()
           appearance.configureWithTransparentBackground()
           
           self.navigationItem.standardAppearance = appearance
           self.navigationItem.scrollEdgeAppearance = appearance
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.layer.masksToBounds = false
        scrollView.layer.cornerRadius = 30
        scrollView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = 10
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.layer.shadowOpacity = 0.9
        imageView.layer.shadowRadius = 10
    }
    
    private func setUI() {
        viewModel.loadData()
        nameLabel.font = UIFont(name: "Pokemon Solid", size: 28) ?? UIFont.systemFont(ofSize: 18)
        nameLabel.setCharacterSpacing(5.0)
        typeView.layer.cornerRadius = 20
        typeView.clipsToBounds = true
        typeView.layer.shadowRadius = 6
        typeView.layer.shadowOpacity = 1.0
        typeView.layer.shadowOffset = CGSize(width: 3, height: 0)
        typeView.layer.shadowColor = UIColor.gray.cgColor
        typeView.layer.masksToBounds = false
    }
    
    private func bindUI() {
        subscription = viewModel.pokemonInfoSubject.sink { [unowned self] completion in
            switch completion {
            case .finished:
                print("Received completion in VC", completion)
            case .failure(let error):
                presentAlert(with: error)
            }
        } receiveValue: { [unowned self] pokemonInfo in
            setPokemonInfo(pokemonInfo)
        }
    }

    private func setPokemonInfo(_ pokemon: PokemonInfo?) {
        guard let pokemon = pokemon else { return }
        nameLabel.text = pokemon.name
        typeLabel.text = pokemon.types.first?.type.name
        height.text = "\(pokemon.height)"
        weight.text = "\(pokemon.weight)"
        
        typeView.backgroundColor = viewModel.colorBackground(pokemon)
        self.backgroundView.applyGradient(colours: [.white.withAlphaComponent(0.8),viewModel.colorBackground(pokemon), .black.withAlphaComponent(0.4)])
        backgroundView.backgroundColor = viewModel.colorBackground(pokemon)
        
        height.textColor = viewModel.colorBackground(pokemon)
        weight.textColor = viewModel.colorBackground(pokemon)

        pokemon.stats.forEach { item in
            let view = StatsView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: 20).isActive = true
            view.progressBar.tintColor = viewModel.colorBackground(pokemon)
            view.config(pokemon: item)

            DispatchQueue.main.async { [unowned self] in
                stackView.addArrangedSubview(view)
            }
        }

        Task {
            let imageURL = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemon.id).png"
            imageView.image = await ImageCacheStore.shared.getCacheImage(for: imageURL)
        }
    }
}


extension UILabel{
    func setCharacterSpacing(_ spacing: CGFloat){
        let attributedStr = NSMutableAttributedString(string: self.text ?? "")
        attributedStr.addAttribute(NSAttributedString.Key.kern, value: spacing, range: NSMakeRange(0, attributedStr.length))
        self.attributedText = attributedStr
    }
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         self.layer.mask = mask
    }
}
