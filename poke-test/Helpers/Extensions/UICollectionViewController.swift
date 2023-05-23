//
//  UICollectionViewController.swift
//  poke-test
//
//  Created by Samantha Cruz on 22/5/23.
//

import UIKit

extension UICollectionViewController {
    func safeAreaLayoutGuideAtSafe() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: guide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
        ])
    }
}

