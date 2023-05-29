//
//  PokemonListViewController.swift
//  poke-test
//
//  Created by Samantha Cruz on 26/5/23.
//

import Combine
import UIKit

enum Mode {
    case addingTeam
    case notTeam
}

final class PokemonListViewController: UIViewController {
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var addTeamButton: UIButton!
    @IBOutlet private var doneButton: UIButton!
    @IBOutlet private var cancelButton: UIButton!
    
    private enum Section: CaseIterable {
        case main
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, PokemonEntry>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, PokemonEntry>
    
    private var viewModel: PokemonListViewModelRepresentable
    private var subscription: AnyCancellable?
    
    init(viewModel: PokemonListViewModelRepresentable) {
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadData()
    }
    
    private func setUI() {
        setTitle("Pokémon", andImage: UIImage(named: "pokemon")!)
        collectionView.delegate = self
        collectionView.register(PokemonViewCell.self)
        collectionView.collectionViewLayout = generateLayout()
        doneButton.isHidden = true
        cancelButton.isHidden = true
        viewModel.loadData()
        applySnapshot(pokemonEntrys: [])
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
    
    private func tapAddTeamButton() {
        viewModel.currentMode = .addingTeam
        addTeamButton.isHidden = true
        doneButton.isHidden = false
        cancelButton.isHidden = false
        reloadData()
    }
    
    private func tapDoneButton() {
        addNameTeam()
    }
    
    private func finishAddingTeam() {
        viewModel.currentMode = .notTeam
        viewModel.selectedPokemons.removeAll()
        addTeamButton.isHidden = false
        doneButton.isHidden = true
        cancelButton.isHidden = true
        reloadData()
    }
    
    private func addNameTeam() {
        if viewModel.selectedPokemons.count >= 3 && viewModel.selectedPokemons.count <= 5 {
            UIAlertController.Builder()
                .withTitle("Add Team Title")
                .withTextField(true)
                .withButton(style: .destructive, title: "Cancel")
                .withButton(title: "Save team") { [unowned self] alert in
                    guard let title = alert.textFields?.first?.text,
                          !title.isEmpty else {
                        presentAlert(with: "Title cannot be empty")
                        return
                    }
                    viewModel.saveTeam(title: title)
                    
                    finishAddingTeam()
                }
                .present(in: self)
        } else {
            presentAlert(with: "The team must contain 3 to 5 pokemons")
        }
    }
    
    
    @IBAction func didTapAddTeam(_ sender: Any) {
        tapAddTeamButton()
    }
    
    @IBAction func didTapDone(_ sender: Any) {
        tapDoneButton()
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        finishAddingTeam()
    }
    
    // MARK: Diffable data source
    
    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell in
            let cell: PokemonViewCell = collectionView.dequeueCell(for: indexPath)
            
            var isSelected = self.viewModel.selectedPokemons.contains(where: { $0.name == item.pokemon.name })
            
            cell.performSelected(isSelected, for: self.viewModel.currentMode)
            cell.configure(item.pokemon)
            cell.contentView.backgroundColor = .white
            
            return cell
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
    
}

extension PokemonListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let pokemon = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch viewModel.currentMode {
        case .addingTeam:
            if let index = viewModel.selectedPokemons.firstIndex(where: { $0.name == pokemon.pokemon.name }) {
                viewModel.selectedPokemons.remove(at: index)
            } else if viewModel.selectedPokemons.count <= 5 {
                viewModel.selectedPokemons.append(pokemon.pokemon)
            }
            reloadData()
        case .notTeam:
            viewModel.didTapItem(model: pokemon.pokemon)
        }
    }
}


extension PokemonListViewController {
    private func generateLayout() -> UICollectionViewCompositionalLayout {
        let listConfig = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
        return UICollectionViewCompositionalLayout.list(using: listConfig)
    }
}
