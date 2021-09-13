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
    
    var movie: Movie?
    var movieInfo: MovieInfo?
    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }
    
    @objc func didReceiveMovieInfoNotification(_ noti: Notification) {
        guard let movieInfo: MovieInfo = noti.userInfo?["movie"] as? MovieInfo else {
            return
        }
        
        self.movieInfo = movieInfo
        
        DispatchQueue.main.async {
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
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMovieInfoNotification(_:)), name: DidReceiveMovieInfoNotification, object: nil)
        
        guard let movie = self.movie else {
            return
        }
        
        requestMovieInfo(movie.id)
        
        self.navigationItem.title = movie.title
        
        DispatchQueue.global().async {
            // Data는 동기 메소드라서 이미지를 불러올 때까지 앱이 프리징되는 걸 막기 위해 백그라운드 큐에 넣어줌
            guard let imageUrl: URL = URL(string: movie.thumb), let imageData: Data = try? Data(contentsOf: imageUrl) else {
                return
            }
            
            DispatchQueue.main.async {
                self.posterImageView.image = UIImage(data: imageData)
            }
        }
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
