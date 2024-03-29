//
//  PokemonInfoViewController.swift
//  poke-test
//
//  Created by Samantha Cruz on 30/5/23.
//

import UIKit
import Combine
import ChameleonFramework

final class PokemonInfoViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet private var stackView: UIStackView!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var nameLabel: UILabel!
    
    @IBOutlet private var typeLabel: UILabel!
    
    @IBOutlet private var height: UILabel!
    
    @IBOutlet private var weight: UILabel!
    
    @IBOutlet private var scrollView: UIScrollView!
    
    @IBOutlet private var backgroundView: UIView!
    
    @IBOutlet private var collectionView: UICollectionView!
    
    @IBOutlet weak var squareImage: UIView!
    
    private enum Section: CaseIterable {
        case main
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, TypeElement>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, TypeElement>
    
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
        
        squareImage.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        squareImage.backgroundColor = .clear
        view.addSubview(squareImage)
        view.bringSubviewToFront(squareImage)
        
        UIView.animate(withDuration: 2.0) {
            self.squareImage.frame = CGRect(x: 0, y: 100, width: 200, height: 100)
        }
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setUI() {
        collectionView.delegate = self
        collectionView.register(PokemonInfoCollectionViewCell.self)
        
        viewModel.loadData()
        nameLabel.font = UIFont(name: "Pokemon Solid", size: 28) ?? UIFont.systemFont(ofSize: 18)
        nameLabel.setCharacterSpacing(5.0)
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
            applySnapshot(pokemon: pokemonInfo?.types ?? [])
        }
    }
    
    private func setPokemonInfo(_ pokemon: PokemonInfo?) {
        guard let pokemon = pokemon else { return }
        nameLabel.text = pokemon.name
        height.text = "\(pokemon.height)"
        weight.text = "\(pokemon.weight)"
        
        Task {
            let imageURL = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemon.id).png"
            imageView.image = await ImageCacheStore.shared.getCacheImage(for: imageURL)
            
            if let myImage = imageView.image {
                backgroundView.backgroundColor = UIColor(gradientStyle: .leftToRight, withFrame: backgroundView.frame, andColors: [pokemon.types.first?.type.color ?? .black, UIColor(averageColorFrom: myImage)])
                
                height.textColor = UIColor(averageColorFrom: myImage)
                weight.textColor = UIColor(averageColorFrom: myImage)
                
                pokemon.stats.forEach { item in
                    let view = StatsView()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.heightAnchor.constraint(equalToConstant: 20).isActive = true
                    view.progressBar.tintColor = UIColor(averageColorFrom: myImage)
                    view.config(pokemon: item)
                    
                    stackView.addArrangedSubview(view)
                }
            }
        }
    }
    
    // MARK: Diffable data source
    
    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell in
            let cell: PokemonInfoCollectionViewCell = collectionView.dequeueCell(for: indexPath)
            
            cell.configCell(item)
            
            cell.backgroundColor = item.type.color
            cell.layer.cornerRadius = 20
            cell.clipsToBounds = true
            cell.layer.shadowRadius = 4
            cell.layer.shadowOpacity = 1.0
            cell.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.layer.shadowColor = item.type.color.cgColor
            cell.layer.masksToBounds = false
            return cell
        }
        return dataSource
    }()
    
    private func applySnapshot(pokemon: [TypeElement]) {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        Section.allCases.forEach { snapshot.appendItems(pokemon, toSection: $0) }
        dataSource.apply(snapshot)
    }
}

extension PokemonInfoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidth: CGFloat = flowLayout.itemSize.width
        let spaceBetweenCell: CGFloat = flowLayout.minimumInteritemSpacing
        let numberOfItems = CGFloat(collectionView.numberOfItems(inSection: section))
        
        let totalWidth = cellWidth * numberOfItems
        let totalSpacingWidth = spaceBetweenCell * (numberOfItems - 1)
        let leftInset = (collectionView.frame.width - CGFloat(totalWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        flowLayout.itemSize =  CGSize(width: 140, height: 46)
        return UIEdgeInsets(top: 5, left: leftInset, bottom: 0, right: rightInset)
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
