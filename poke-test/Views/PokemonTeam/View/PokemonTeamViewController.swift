//
//  PokemonTeamViewController.swift
//  poke-test
//
//  Created by Samantha Cruz on 12/10/23.
//

import UIKit

final class PokemonTeamViewController: UICollectionViewController {
    
    private enum Section: CaseIterable {
        case main
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Pokemon>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Pokemon>
    
    private let viewModel: PokemonTeamViewModelRepresentable
    
    init(viewModel: PokemonTeamViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: Self.generateLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        title = viewModel.team.title
        safeAreaLayoutGuideAtSafe()
        applySnapshot()
    }
    
    // MARK: Diffable data source
    
    private let registerPokedexCell = UICollectionView.CellRegistration<UICollectionViewListCell, Pokemon> { cell, indexPath, pokemon in
        var configuration = cell.defaultContentConfiguration()
        configuration.text = pokemon.name.capitalized
        
        cell.contentConfiguration = configuration
    }
    
    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell in
            collectionView.dequeueConfiguredReusableCell(using: self.registerPokedexCell, for: indexPath, item: item)
        }
        return dataSource
    }()
    
    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        Section.allCases.forEach { snapshot.appendItems(viewModel.team.pokemons, toSection: $0) }
        dataSource.apply(snapshot)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let pokedex = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.didTapItem(model: pokedex)
    }
}

extension PokemonTeamViewController {
    static private func generateLayout() -> UICollectionViewCompositionalLayout {
        let listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: listConfig)
    }
}

