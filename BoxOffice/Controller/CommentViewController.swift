//
//  CommentViewController.swift
//  BoxOffice
//
//  Created by kwon on 2021/09/21.
//

import UIKit

class CommentViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gradeImage: UIImageView!
    @IBOutlet weak var nicknameField: UITextField!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var ratingStars: UIStackView!
    
    var movie: Movie?
    var stars: [UIButton]?
        
    @IBAction func touchUpCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let movie = self.movie else {
            return
        }
        
        self.titleLabel.text = movie.title
        switch movie.grade {
        case 12:
            self.gradeImage.image = UIImage(named: "ic_12")
        case 15:
            self.gradeImage.image = UIImage(named: "ic_15")
        case 19:
            self.gradeImage.image = UIImage(named: "ic_19")
        default:
            self.gradeImage.image = UIImage(named: "ic_allages")
        }
        
        if let nickname = UserInfo.shared.nickname {
            self.nicknameField.text = nickname
        }
        
        guard let stars: [UIButton] = self.ratingStars.subviews.filter({ $0 is UIButton }) as? [UIButton] else {
            return
        }
        
        self.stars = stars
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchStars(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchStars(touches)
    }
    
    func touchStars(_ touches: Set<UITouch>) {
        guard let stars = self.stars else {
            return
        }
        
        guard let touch = touches.first?.location(in: self.view) else {
            return
        }
        
        guard let starFirst = stars.first else {
            return
        }
        
        // 점수를 0으로 만들기 위해 첫번째 별 옆에 절반되는 공간을 만듦
        let starFrameLeftOut = self.view.convert(CGRect.init(x: starFirst.frame.minX - starFirst.frame.width / 2, y: starFirst.frame.minY, width: starFirst.frame.width / 2, height: starFirst.frame.height), from: starFirst.superview)
        
        for (index, star) in stars.enumerated() {
            // self.view.convert(star.frame, from: star.superview)에서 star.frame을 좌우로 분리
            let starFrameLeft = self.view.convert(CGRect.init(x: star.frame.minX, y: star.frame.minY, width: star.frame.width / 2, height: star.frame.height), from: star.superview)
            
            let starFrameRight = self.view.convert(CGRect.init(x: star.frame.midX, y: star.frame.minY, width: star.frame.width / 2, height: star.frame.height), from: star.superview)
            
            if starFrameLeft.contains(touch) {
                self.rateLabel.text = String(index * 2 + 1)
                
                for i in 0..<index {
                    stars[i].setImage(UIImage(named: "ic_star_large_full"), for: .normal)
                }
                
                stars[index].setImage(UIImage(named: "ic_star_large_half"), for: .normal)
                
                for i in index+1..<stars.count {
                    stars[i].setImage(UIImage(named: "ic_star_large"), for: .normal)
                }
            }
            
            if starFrameRight.contains(touch) {
                self.rateLabel.text = String(index * 2 + 2)
                
                for i in index+1..<stars.count {
                    stars[i].setImage(UIImage(named: "ic_star_large"), for: .normal)
                }
                
                for i in 0...index {
                    stars[i].setImage(UIImage(named: "ic_star_large_full"), for: .normal)
                }
            }
            
            if starFrameLeftOut.contains(touch) {
                self.rateLabel.text = String(0)
                
                for star in stars {
                    star.setImage(UIImage(named: "ic_star_large"), for: .normal)
                }
            }
        }
    }
}
