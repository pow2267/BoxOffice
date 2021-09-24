//
//  MovieViewController.swift
//  BoxOffice
//
//  Created by kwon on 2021/09/10.
//

import UIKit

class MovieViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var gerneLabel: UILabel!
    @IBOutlet weak var rateImage: UIImageView!
    @IBOutlet weak var reservationRateLabel: UILabel!
    @IBOutlet weak var userRatingLabel: UILabel!
    @IBOutlet weak var audienceLabel: UILabel!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    @IBOutlet weak var synopsis: UILabel!
    @IBOutlet weak var directors: UILabel!
    @IBOutlet weak var actors: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var commentButton: UIImageView!
    
    var movie: Movie?
    var movieInfo: MovieInfo?
    var comments: [Comment]?
    
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }
    
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }
    
    @objc func touchUpCommentButton() {
        guard let commentViewController = UIStoryboard.init(name: "Main", bundle: .main).instantiateViewController(identifier: "commentViewController") as? CommentViewController else {
            return
        }
        
        guard let movie = self.movie else {
            return
        }
        
        commentViewController.movie = movie
        
        self.present(commentViewController, animated: true, completion: nil)
    }
    
    @objc func dismissFullscreen(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    @objc func touchUpMoviePoster() {
        let newImageView = UIImageView()
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = UIColor.black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullscreen(_:)))
        newImageView.addGestureRecognizer(gestureRecognizer)
        
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        DispatchQueue.global().async {
            guard let movieInfo = self.movieInfo, let imageUrl: URL = URL(string: movieInfo.image), let imageData: Data = try? Data(contentsOf: imageUrl) else {
                return
            }
            
            DispatchQueue.main.async {
                guard let image = UIImage(data: imageData) else {
                    return
                }

                newImageView.image = image
            }
        }
    }
    
    @objc func didReceiveCommentNotification(_ noti: Notification) {
        guard let comments: [Comment] = noti.userInfo?["comments"] as? [Comment] else {
            return
        }
        
        self.comments = comments
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func didReceiveMovieInfoNotification(_ noti: Notification) {
        guard let movieInfo: MovieInfo = noti.userInfo?["movie"] as? MovieInfo else {
            return
        }
        
        self.movieInfo = movieInfo
        
        DispatchQueue.global().async {
            guard let imageUrl: URL = URL(string: movieInfo.image), let imageData: Data = try? Data(contentsOf: imageUrl) else {
                return
            }
                
            DispatchQueue.main.async {
                self.posterImageView.image = UIImage(data: imageData)
            }
        }
                
        // Q. 왜 main 스레드에 넣어야 하나요?
        DispatchQueue.main.async {
            self.navigationItem.title = movieInfo.title
                        
            self.titleLabel.text = movieInfo.title
            self.releaseDateLabel.text = movieInfo.releaseDate
            self.gerneLabel.text = movieInfo.genreAndDuration
            self.reservationRateLabel.text = movieInfo.reservation
            self.userRatingLabel.text = String(movieInfo.userRating)
            self.audienceLabel.text = self.numberFormatter.string(from: NSNumber(value: movieInfo.audience))
            
            switch movieInfo.grade {
            case 12:
                self.rateImage.image = UIImage(named: "ic_12")
            case 15:
                self.rateImage.image = UIImage(named: "ic_15")
            case 19:
                self.rateImage.image = UIImage(named: "ic_19")
            default:
                self.rateImage.image = UIImage(named: "ic_allages")
            }
            
            // reset stars
            self.star1.image = UIImage(named: "ic_star_large")
            self.star2.image = UIImage(named: "ic_star_large")
            self.star3.image = UIImage(named: "ic_star_large")
            self.star4.image = UIImage(named: "ic_star_large")
            self.star5.image = UIImage(named: "ic_star_large")
            
            if movieInfo.userRating >= 1.0 {
                self.star1.image = UIImage(named: "ic_star_large_half")
            }
             
            if movieInfo.userRating >= 2.0 {
                self.star1.image = UIImage(named: "ic_star_large_full")
            }
            
            if movieInfo.userRating >= 3.0 {
                self.star2.image = UIImage(named: "ic_star_large_half")
            }
            
            if movieInfo.userRating >= 4.0 {
                self.star2.image = UIImage(named: "ic_star_large_full")
            }
            
            if movieInfo.userRating >= 5.0 {
                self.star3.image = UIImage(named: "ic_star_large_half")
            }
            
            if movieInfo.userRating >= 6.0 {
                self.star3.image = UIImage(named: "ic_star_large_full")
            }
            
            if movieInfo.userRating >= 7.0 {
                self.star4.image = UIImage(named: "ic_star_large_half")
            }
            
            if movieInfo.userRating >= 8.0 {
                self.star4.image = UIImage(named: "ic_star_large_full")
            }
            
            if movieInfo.userRating >= 9.0 {
                self.star5.image = UIImage(named: "ic_star_large_half")
            }
            
            if movieInfo.userRating == 10.0 {
                self.star5.image = UIImage(named: "ic_star_large_full")
            }
            
            self.synopsis.text = movieInfo.synopsis
            self.directors.text = movieInfo.director
            self.actors.text = movieInfo.actor
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMovieInfoNotification(_:)), name: DidReceiveMovieInfoNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveCommentNotification(_:)), name: DidReceiveCommentNotification, object: nil)
        
        guard let movie = self.movie else {
            return
        }
        
        requestMovieInfo(movie.id)
        requestComments(movie.id)
        
        let posterTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.touchUpMoviePoster))
        self.posterImageView.addGestureRecognizer(posterTapGestureRecognizer)
        self.posterImageView.isUserInteractionEnabled = true
        
        let commentButtonTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.touchUpCommentButton))
        self.commentButton.addGestureRecognizer(commentButtonTapGestureRecognizer)
        self.commentButton.isUserInteractionEnabled = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MovieViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CommentTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CommentTableViewCell else {
            preconditionFailure("테이블 뷰 셀 오류")
        }
        
        guard let comment = self.comments?[indexPath.row] else {
            preconditionFailure("코멘트를 불러올 수 없음")
        }
        
        cell.nicknameLabel.text = comment.writer
        cell.commentLabel.text = comment.contents
        cell.creationDateLabel.text = self.dateFormatter.string(from: NSDate(timeIntervalSince1970: comment.timestamp) as Date)
        
        // 별 이미지 초기화
        cell.star1.image = UIImage(named: "ic_star_large")
        cell.star2.image = UIImage(named: "ic_star_large")
        cell.star3.image = UIImage(named: "ic_star_large")
        cell.star4.image = UIImage(named: "ic_star_large")
        cell.star5.image = UIImage(named: "ic_star_large")
        
        if comment.rating >= 1.0 {
            cell.star1.image = UIImage(named: "ic_star_large_half")
        }
         
        if comment.rating >= 2.0 {
            cell.star1.image = UIImage(named: "ic_star_large_full")
        }
        
        if comment.rating >= 3.0 {
            cell.star2.image = UIImage(named: "ic_star_large_half")
        }
        
        if comment.rating >= 4.0 {
            cell.star2.image = UIImage(named: "ic_star_large_full")
        }
        
        if comment.rating >= 5.0 {
            cell.star3.image = UIImage(named: "ic_star_large_half")
        }
        
        if comment.rating >= 6.0 {
            cell.star3.image = UIImage(named: "ic_star_large_full")
        }
        
        if comment.rating >= 7.0 {
            cell.star4.image = UIImage(named: "ic_star_large_half")
        }
        
        if comment.rating >= 8.0 {
            cell.star4.image = UIImage(named: "ic_star_large_full")
        }
        
        if comment.rating >= 9.0 {
            cell.star5.image = UIImage(named: "ic_star_large_half")
        }
        
        if comment.rating == 10.0 {
            cell.star5.image = UIImage(named: "ic_star_large_full")
        }
        
        return cell
    }
}

extension MovieViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.tableViewHeight.constant = self.tableView.contentSize.height
        }
    }
}
