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
    @IBOutlet weak var ratingStars: StarsStackView!
    
    var movie: Movie?
        
    @IBAction func touchUpCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func changeRate(_ sender: UIButton) {
        self.rateLabel.text = String(sender.tag)
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
        
        for star in stars {
            star.addTarget(self, action: #selector(changeRate(_:)), for: .touchUpInside)
        }
    }
}
