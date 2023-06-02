//
//  StatsView.swift
//  poke-test
//
//  Created by Samantha Cruz on 31/5/23.
//

import UIKit

final class StatsView: UIView {
    
    @IBOutlet private var containerView: UIView!

    @IBOutlet private var nameStat: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        let viewFromXib = Bundle.main.loadNibNamed("StatsView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = bounds
        addSubview(viewFromXib)
        
        progressBar.progress = 0.0
        
        progressBar.layer.cornerRadius = 10
        progressBar.clipsToBounds = true
        progressBar.layer.sublayers![1].cornerRadius = 10
        progressBar.subviews[1].clipsToBounds = true
    }
    
    
    func config(pokemon: Stat) {
        nameStat.text = pokemon.stat.name
        let myFloat = Float(pokemon.baseStat)/100
        progressBar.progress = myFloat
    }
    

}
