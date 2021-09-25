//
//  StarsStackView.swift
//  BoxOffice
//
//  Created by kwon on 2021/09/24.
//

import UIKit

class StarsStackView: UIStackView {
    var starRating: Int = 0

    let starEmpty: String = "ic_star_large"
    let starHalf: String = "ic_star_large_half"
    let starFull: String = "ic_star_large_full"
    
    override func draw(_ rect: CGRect) {
        guard let stars: [UIButton] = self.subviews.filter({ $0 is UIButton }) as? [UIButton] else {
            return
        }
        
        var starTag = 2
        
        for star in stars {
            star.addTarget(self, action: #selector(pressed(_:)), for: .touchUpInside)
            star.tag = starTag
            starTag += 2
        }
    }
    
    @objc func pressed(_ sender: UIButton) {
        guard let stars: [UIButton] = self.subviews.filter({ $0 is UIButton }) as? [UIButton] else {
            return
        }
        
        self.starRating = sender.tag
        
        for star in stars {
            if star.tag > sender.tag {
                star.setImage(UIImage(named: self.starEmpty), for: .normal)
            } else {
                star.setImage(UIImage(named: self.starFull), for: .normal)
            }
        }
    }
}
