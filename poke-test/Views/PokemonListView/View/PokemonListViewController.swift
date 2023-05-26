//
//  PokemonListViewController.swift
//  poke-test
//
//  Created by Samantha Cruz on 26/5/23.
//

import Combine
import UIKit

final class PokemonListViewController: UICollectionViewController {
    
    private enum Section: CaseIterable {
        case main
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, PokemonEntry>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, PokemonEntry>
    
    private var subscription: AnyCancellable?
    private var viewModel: PokemonListViewModelRepresentable
    
    init(viewModel: PokemonListViewModelRepresentable) {
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
        setTitle("Pokémon", andImage: UIImage(named: "pokemon")!)
        safeAreaLayoutGuideAtSafe()
        viewModel.loadData()
    }
    
    private func bindUI() {
        subscription = viewModel.pokemonListSubject.sink { [unowned self] completion in
            switch completion {
            case .finished:
                print("Received completion in VC", completion)
            case .failure(let error):
                presentAlert(with: error)
            }
        } receiveValue: { [unowned self] pokemonEntrys in
            applySnapshot(pokemonEntrys: pokemonEntrys)
        }
    }

    private let registerPokemonCell = UICollectionView.CellRegistration<UICollectionViewListCell, Pokemon> { cell, indexPath, pokemon in
        var configuration = cell.defaultContentConfiguration()
        configuration.text = pokemon.name
        configuration.textProperties.font = UIFont(name: "PokemonGB", size: 18) ?? UIFont.systemFont(ofSize: 18)
        
        cell.accessories = [.disclosureIndicator()]
        cell.contentConfiguration = configuration
    }
    
    // MARK: Diffable data source
    
    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell in
            collectionView.dequeueConfiguredReusableCell(using: self.registerPokemonCell, for: indexPath, item: item.pokemon)
        }
        return dataSource
    }()
    
    private func applySnapshot(pokemonEntrys: [PokemonEntry]) {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        Section.allCases.forEach { snapshot.appendItems(pokemonEntrys, toSection: $0) }
        dataSource.apply(snapshot)
    }
    
    private func reloadData() {
        DispatchQueue.main.async { [unowned self] in
            collectionView.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let pokemon = dataSource.itemIdentifier(for: indexPath) else { return }
        
    }
}

extension PokemonListViewController {
    static private func generateLayout() -> UICollectionViewCompositionalLayout {
        let listConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: listConfig)
    }
}
