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
        
        progressBar.layer.cornerRadius = 10
        progressBar.clipsToBounds = true
        progressBar.layer.sublayers![1].cornerRadius = 10
        progressBar.subviews[1].clipsToBounds = true
    }
    
    
    func config(pokemon: Stat) {
        nameStat.text = pokemon.stat.name
        let myFloat = Float(pokemon.baseStat)/100
        
        self.progressBar.layer.sublayers?.forEach { $0.removeAllAnimations() }
        self.progressBar.setProgress(0.0, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            self.progressBar.setProgress(myFloat, animated: false)
            
            UIView.animate(withDuration: 2.0, delay: 0, options: [], animations: { [unowned self] in
                self.progressBar.layoutIfNeeded()
            })
        }
    }
}
