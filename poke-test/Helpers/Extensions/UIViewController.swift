//
//  UIViewController.swift
//  poke-test
//
//  Created by Samantha Cruz on 25/5/23.
//

import UIKit

extension UIViewController {
    func setTitle(_ title: String, andImage image: UIImage) {
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        let imageView = UIImageView(image: image)
        let titleView = UIStackView(arrangedSubviews: [imageView, titleLbl])
        titleView.axis = .horizontal
        titleView.spacing = 10
        navigationItem.titleView = titleView
    }
}
