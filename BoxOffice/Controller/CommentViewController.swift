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
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var ratingStars: UIStackView!
    
    var movie: Movie?
    var stars: [UIButton]?
    let emptyStar: String = "ic_star_large"
    let halfStar: String = "ic_star_large_half"
    let fullStar: String = "ic_star_large_full"
    let placeholder: String = "한줄평을 작성해 주세요."
    
    @IBAction func touchUpSubmitButton() {
        let alert: UIAlertController = UIAlertController(title: "오류", message: "닉네임과 한줄평을 모두 작성해 주세요.", preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        
        guard let nickname: String = self.nicknameField.text, nickname.count > 0 else {
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let contents: String = self.commentTextView.text, contents.count > 0, contents != self.placeholder else {
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let movieId: String = self.movie?.id else {
            return
        }
        
        guard let rating: Double = Double(self.rateLabel.text ?? "0"), rating > 0 else {
            let rateAlert: UIAlertController = UIAlertController(title: "오류", message: "별점은 1점 이상부터 입력 가능합니다.", preferredStyle: .alert)
            rateAlert.addAction(cancelAction)
            
            self.present(rateAlert, animated: true, completion: nil)
            return
        }
        
        guard let url: URL = URL(string: "https://connect-boxoffice.run.goorm.io/comment") else {
            return
        }
        
        let session: URLSession = URLSession(configuration: .default)
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let comment = Comment(id: nil, rating: rating, timestamp: nil, writer: nickname, movieId: movieId, contents: contents)
        
        do {
            let data = try JSONEncoder().encode(comment)
            
            let uploadTask: URLSessionUploadTask = session.uploadTask(with: urlRequest, from: data, completionHandler: {(data: Data?, urlResponse: URLResponse?, error: Error?) in
                if let error = error {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        let errorAlert: UIAlertController = UIAlertController(title: "한줄평 작성 오류", message: "오류가 발생해 한줄평 작성에 실패했습니다. 다시 시도해 주세요.", preferredStyle: .alert)
                        
                        errorAlert.addAction(cancelAction)
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                    return
                } else {
                    requestComments(movieId)
                    UserInfo.shared.nickname = nickname
                    DispatchQueue.main.async {
                        self.touchUpCancelButton()
                    }
                }
            })
            
            uploadTask.resume()
        } catch (let err) {
            print(err.localizedDescription)
        }
    }
        
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
        
        self.commentTextView.layer.borderWidth = 1.0
        self.commentTextView.layer.borderColor = UIColor.systemGray5.cgColor
        self.commentTextView.layer.cornerRadius = 5.5
        self.commentTextView.text = self.placeholder
        self.commentTextView.textColor = UIColor.systemGray3
        self.commentTextView.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
                    stars[i].setImage(UIImage(named: self.fullStar), for: .normal)
                }
                
                stars[index].setImage(UIImage(named: self.halfStar), for: .normal)
                
                for i in index+1..<stars.count {
                    stars[i].setImage(UIImage(named: self.emptyStar), for: .normal)
                }
            }
            
            if starFrameRight.contains(touch) {
                self.rateLabel.text = String(index * 2 + 2)
                
                for i in index+1..<stars.count {
                    stars[i].setImage(UIImage(named: self.emptyStar), for: .normal)
                }
                
                for i in 0...index {
                    stars[i].setImage(UIImage(named: self.fullStar), for: .normal)
                }
            }
            
            if starFrameLeftOut.contains(touch) {
                self.rateLabel.text = String(0)
                
                for star in stars {
                    star.setImage(UIImage(named: self.emptyStar), for: .normal)
                }
            }
        }
    }
}

extension CommentViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.systemGray3 {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = self.placeholder
            textView.textColor = UIColor.systemGray3
        }
    }
}
