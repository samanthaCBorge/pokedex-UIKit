//
//  HomeViewController.swift
//  poke-test
//
//  Created by Samantha Cruz on 22/5/23.
//

import UIKit
import Combine

final class HomeViewController: UICollectionViewController {
    
    private enum Section: CaseIterable {
        case main
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Region>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Region>
    
    private var subscription: AnyCancellable?
    private let viewModel: HomeViewModelRepresentable
    
    init(viewModel: HomeViewModelRepresentable) {
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
        navigationController?.isNavigationBarHidden = false
        navigationItem.setHidesBackButton(true, animated: false)
        title = "Regions"
        safeAreaLayoutGuideAtSafe()
        viewModel.loadData()
    }
    
    private func bindUI() {
        subscription = viewModel.regionListSubject.sink { [unowned self] completion in
            switch completion {
            case .finished:
                print("Received completion in VC", completion)
            case .failure(let error):
                presentAlert(with: error)
            }
        } receiveValue: { [unowned self] regions in
            applySnapshot(regions: regions)
        }
    }
    
    // MARK: Diffable data source
    
    private let registerRegionCell = UICollectionView.CellRegistration<UICollectionViewListCell, Region> { cell, indexPath, region in
        var configuration = cell.defaultContentConfiguration()
        configuration.text = region.name.capitalized
        
        cell.contentConfiguration = configuration
    }
    
    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell in
            collectionView.dequeueConfiguredReusableCell(using: self.registerRegionCell, for: indexPath, item: item)
        }
        return dataSource
    }()
    
    private func applySnapshot(regions: [Region]) {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        Section.allCases.forEach { snapshot.appendItems(regions, toSection: $0) }
        dataSource.apply(snapshot)
    }
}

extension HomeViewController {
    static private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let fraction: CGFloat = 1 / 2
            
            // Item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(fraction))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            // Section
            
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        return layout
    }
}
