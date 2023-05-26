//
//  PokedexListViewController.swift
//  poke-test
//
//  Created by Samantha Cruz on 25/5/23.
//

import UIKit
import Combine

final class PokedexListViewController: UICollectionViewController {
    
    private enum Section: CaseIterable {
        case main
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Pokedex>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Pokedex>
    
    private var subscription: AnyCancellable?
    private let viewModel: PokedexListViewModelRepresentable
    
    init(viewModel: PokedexListViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: Self.generateLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bindUI()
    }
    
    private func setUI() {
        setTitle("Pokédex", andImage: UIImage(named: "pokedex")!)
        safeAreaLayoutGuideAtSafe()
        viewModel.loadData()
    }
    
    private func bindUI() {
        subscription = viewModel.pokedexListSubject.sink { [unowned self] completion in
            switch completion {
            case .finished:
                print("Received completion in VC", completion)
            case .failure(let error):
                presentAlert(with: error)
            }
        } receiveValue: { [unowned self] pokedexes in
            applySnapshot(pokedexes: pokedexes)
        }
    }
    
    // MARK: Diffable data source
    
    private let registerPokedexCell = UICollectionView.CellRegistration<UICollectionViewListCell, Pokedex> { cell, indexPath, pokedex in
        var configuration = cell.defaultContentConfiguration()
        configuration.text = pokedex.name
        configuration.textProperties.font = UIFont(name: "PokemonGB", size: 18) ?? UIFont.systemFont(ofSize: 18)
        
        cell.accessories = [.disclosureIndicator()]
        cell.contentConfiguration = configuration
    }
    
    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell in
            collectionView.dequeueConfiguredReusableCell(using: self.registerPokedexCell, for: indexPath, item: item)
        }
        return dataSource
    }()
    
    private func applySnapshot(pokedexes: [Pokedex]) {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        Section.allCases.forEach { snapshot.appendItems(pokedexes, toSection: $0) }
        dataSource.apply(snapshot)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let pokedex = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.didTapItem(model: pokedex)
    }
}

extension PokedexListViewController {
    static private func generateLayout() -> UICollectionViewCompositionalLayout {
        let listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: listConfig)
    }
}

